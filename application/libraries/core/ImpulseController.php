<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * The replacement IMPULSE controller class. All controllers should extend from this rather than the builtin
 */
class ImpulseController extends CI_Controller {

	protected static $sys;
	protected static $int;
	protected static $addr;
    protected static $mHost;
	protected static $fwSys;
	protected static $sPort;
	protected static $sidebar;
	protected $tableTemplate;
	
	public function __construct() {
		parent::__construct();
		$this->viewTemplate = array (
			'table_open'          => '<table border="0" cellpadding="4" cellspacing="0">',

			'heading_row_start'   => '<tr>',
			'heading_row_end'     => '</tr>',
			'heading_cell_start'  => '<th>',
			'heading_cell_end'    => '</th>',

			'row_start'           => '<tr bgcolor=#cccccc>',
			'row_end'             => '</tr>',
			'cell_start'          => '<td>',
			'cell_end'            => '</td>',

			'row_alt_start'       => '<tr bgcolor=#b9b9b9>',
			'row_alt_end'         => '</tr>',
			'cell_alt_start'      => '<td>',
			'cell_alt_end'        => '</td>',

			'table_close'         => '</table>'
		);
		$this->table->set_template($this->viewTemplate);
		
		try {
			$this->api->initialize($this->impulselib->get_username());
		}
		catch(ObjectNotFoundException $onfE) {
			$this->_error("Unable to find your username (".$this->impulselib->get_username().") Make sure the LDAP server is functioning properly.");
		}
		catch(DBException $dbE) {
			$this->_error("Database connection error: ".$dbE->getMessage());
		}
		
		// Check if the session was started
		if(session_id() == "") { 
			session_start();
		}
		
		if(isset($_SESSION['sidebar'])) {
			#self::$sidebar = unserialize($_SESSION['sidebar']);
			// @todo: Undo this
			self::$sidebar = new Sidebar();
		}
		else {
			self::$sidebar = new Sidebar();
			$_SESSION['sidebar'] = serialize(self::$sidebar);
		}
		
	}
    
    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
    
	/**
	 * Print an error message (thrown by the DB)
     * @param $message  The message to display
     * @return void
     */
	protected function _error($message) {
		// Navbar
		#$navModes['CANCEL'] = current_url();
		#$navbar = new Navbar("Error", $navModes, null);

		$data['message'] = $message;
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = '<div class="sidebar"></div>';
		$info['navbar'] = $this->load->view('core/navbar_error',null,TRUE);
		$info['data'] = $this->load->view('core/error',$data,TRUE);
		$info['title'] = "Error";
		
		// Exit PHP loading the view
		exit($this->load->view('core/main',$info,TRUE));
	}
	
	/**
	 * Print a success message
     * @param $message  The message to display
     * @return void
     */
	protected function _success($message) {
		// Navbar
		$navOptions['Back'] = $this->input->server('HTTP_REFERER');
		$navbar = new Navbar("Success", null, $navOptions);
		
		$data['message'] = $message;
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('core/success',$data,TRUE);
		$info['title'] = "Success";
		
		// Load the main view
		$this->load->view('core/main',$info);
	}	
	
	/**
	 * Print a warning message
     * @param $message  The message to display
     * @return void
     */
	protected function _warning($message) {
		return $this->load->view('core/warning',array("message"=>$message),TRUE);
	}
	
	protected function _load_system($systemName=NULL,$complete=FALSE) {
		try {
			if($this->impulselib->get_active_system() instanceof System) {
				if($this->impulselib->get_active_system()->get_system_name() == $systemName) {
					#@todo: Fix this
					self::$sys = $this->impulselib->get_active_system();
				}
				else {
					self::$sys = $this->api->systems->get->system($systemName,$complete);
				}
			}
			else {
				self::$sys = $this->api->systems->get->system($systemName,$complete);
			}
		}
		catch(ObjectNotFoundException $onfE) {
			try {
				self::$sys = $this->api->systems->get->system($systemName,$complete);
			}
			catch(Exception $e) {
				$this->_error($e->getMessage());
			}
		}
		catch(Exception $e) {
			$this->_error($e->getMessage());
		}
		
		return self::$sys;
    }
	
	protected function _load_interface($mac,$complete=FALSE) {
		try {
			self::$int = $this->api->systems->get->system_interface_data($mac,$complete);
			return self::$int;
		}
		catch(Exception $e) {
			$this->_error($e->getMessage());
		}
	}

	protected function _load_address($address) {
		try {
			self::$addr = $this->api->systems->get->system_interface_address($address,TRUE);
			return self::$addr;
		}
		catch(Exception $e) {
			$this->_error($e->getMessage());
		}
	}

    protected function _load_metahost($metahostName) {
        try {
			self::$mHost = $this->api->firewall->get->metahost($metahostName,true);
		}
		catch (DBException $dbE) {
			$this->_error($dbE->getMessage());
		}
		catch (AmbiguousTargetException $atE) {
			$this->_error($atE->getMessage());
		}
		catch (ObjectNotFoundException $onfE) {
			$this->_error($onfE->getMessage());
		}
    }

    protected function _load_switchports($systemName) {
        try {
            $sPorts = $this->api->network->get->switchports($systemName);
            foreach($sPorts as $sPort) {
                self::$sys->add_switchport($sPort);
            }
        }
        catch (DBException $dbE) {
            $this->_error($dbE->getMessage());
        }
    }
	

	protected function _load_addresses() {

        // View data
		$addressViewData = "";

        // Array of address objects
		try {
			$addrs = $this->api->systems->get->system_interface_addresses(self::$int->get_mac(), true);

			// For each of the address objects, draw it's box and append it to the view
			foreach($addrs as $addr) {
				$navOptions['DNS Records'] = "/dns/view/".rawurlencode($addr->get_address());
				if($addr->get_dynamic() != TRUE) {
					$navOptions['Firewall Rules'] = "/firewall/rules/view/".rawurlencode($addr->get_address());
				}
				$navModes['EDIT'] = "/address/edit/".rawurlencode($addr->get_address());
				$navModes['DELETE'] = "/address/delete/".rawurlencode($addr->get_address());
								
				$navbar = new Navbar("Address", $navModes, $navOptions);
				$addressViewData .= $this->load->view('systems/address',array('addr'=>$addr, 'navbar'=>$navbar),TRUE);
				self::$int->add_address($addr);
			}
			
			return $addressViewData;
		}
		// There were no addresses
		catch (ObjectNotFoundException $onfE) {
			return $this->_warning("No addresses found!");
		}
	}
}
/* End of file ImpulseController.php */
/* Location: ./application/libraries/core/ImpulseController.php */
