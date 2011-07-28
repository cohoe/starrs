<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * The replacement IMPULSE controller class. All controllers should extend from this rather than the builtin
 */
class ImpulseController extends CI_Controller {

	protected static $sys;
	protected static $int;
	protected static $addr;
    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
    
	/**
	 * Print an error message (thrown by the DB)
     * @param $message  The message to display
     * @return void
     */
	protected function _error($message) {
		// Navbar
		$navModes['CANCEL'] = current_url();
		$navbar = new Navbar("Error", $navModes, null);

		$data['message'] = $message;
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('core/error',$data,TRUE);
		$info['title'] = "Error";
		
		// Load the main view
		return $this->load->view('core/main',$info,TRUE);
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
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
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
		// Navbar
        #$navbar = new Navbar("Warning", null, null);
		
		$data['message'] = $message;
		
		// Load view data
		#$info['header'] = $this->load->view('core/header',"",TRUE);
		#$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		#$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		#$info['data'] = $this->load->view('core/warning',$data,TRUE);
		#$info['title'] = "Warning";
		
		// Load the main view
		#$this->load->view('core/main',$info);
		
		return $this->load->view('core/warning',$data,TRUE);
	}
	
	protected function _load_system() {
		// Establish the system and address objects
        try {
            self::$sys = $this->impulselib->get_active_system();
        }
        catch (ObjectNotFoundException $onfE) {
			 exit($this->_error($onfE->getMessage()));
            $this->_error($onfE->getMessage());
            return;
        }
	}
	
	protected function _load_address($address) {
		try {
			$ints = self::$sys->get_interfaces();
			foreach ($ints as $int) {
				try {
					self::$addr = $int->get_address($address);
					if(self::$addr instanceof InterfaceAddress) {
						self::$int = $int;
						break;
					}
				}
				catch (ObjectException $apiE) {
					$addr = NULL;
				}
			}
		}
		catch (ObjectException $apiE) {
			$this->_error($apiE->getMessage());
			return;
		}
	}
}

/* End of file ImpulseController.php */
/* Location: ./application/libraries/core/ImpulseController.php */
