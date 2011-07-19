<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "controllers/systems.php");

/**
 * 
 */
class Dns extends IMPULSE_Controller {
	
	private static $sys;
	private static $int;
	private static $addr;
	
	public function index() {
	
	}
	
	public function view($address=NULL) {
	
		if($address==NULL) {
			$this->error("No address specified");
			return;
		}
		if(!(self::$sys instanceof System)) {
			$this->_load_system();
		}
		if(!(self::$addr instanceof InterfaceAddress)) {
			$this->_load_address($address);
		}

		$addr =& self::$addr;
		
		// Navbar
		$navOptions['Overview'] = "/addresses/view/".$addr->get_mac()."/".$addr->get_address()."/overview";
		$navOptions['DNS Records'] = "/dns/view/".$addr->get_address();
		$navOptions['Firewall Rules'] = "/addresses/view/".$addr->get_mac()."/".$addr->get_address()."/firewall";
		
		$navModes['CREATE'] = "/dns/create/".$addr->get_address();
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$viewData['address'] = $addr;
		$data = $this->load->view('dns/address', $viewData, TRUE);
		$info['title'] = "DNS - ".$addr->get_address();
		$navbar = new Navbar("DNS for ".$addr->get_address(), $navModes, $navOptions);
		
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $data;

		// Load the main view
		$this->load->view('core/main',$info);
	
	}
	
	public function create($address) {
	
		if($address==NULL) {
			$this->error("No address specified");
			return;
		}
		if(!(self::$sys instanceof System)) {
			$this->_load_system();
		}
		if(!(self::$addr instanceof InterfaceAddress)) {
			$this->_load_address($address);
		}
		if(self::$addr->get_address() != $address) {
			echo self::$sys->get_system_name();
		}
		
		$addr =& self::$addr;
		
		if($this->input->post('typeSubmit')) {
			// Navbar
			$navModes['CANCEL'] = "/dns/view/".$addr->get_address();
			$navbar = new Navbar("Create DNS Record", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);

			// Get the preset form data for drop down lists and things
			$form['addr'] = $addr;
			$form['type'] = $this->input->post('type');
			$form['user'] = $this->impulselib->get_username();
			$form['zones'] = $this->api->dns->get_zones($form['user']);

			// Are you an admin?
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}

			// Continue loading view data
			$info['data'] = $this->load->view('dns/create',$form,TRUE);
			$info['title'] = "Create DNS Address";

			// Load the main view
			$this->load->view('core/main',$info);
		}
		elseif($this->input->post('recordSubmit')) {
			$record = $this->_create($addr);
			self::$int->add_address($addr);
			self::$sys->add_interface(self::$int);
			$this->impulselib->set_active_system(self::$sys);
			redirect(base_url()."/dns/view/".$addr->get_address(),'location');
		}
		else {
			// Navbar
			$navModes['CANCEL'] = "/dns/view/".$addr->get_address();
			$navbar = new Navbar("Create DNS Record", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);

			// Get the preset form data for drop down lists and things
			$form['address'] = $addr;
			$form['types'] = $this->api->dns->get_record_types();

			// Are you an admin?
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}

			// Continue loading view data
			$info['data'] = $this->load->view('dns/typeselect',$form,TRUE);
			$info['title'] = "Create DNS Address";

			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	public function edit($obj) {}
	
	public function delete($obj) {}
	
	private function _create(&$addr) {
		if(!$this->input->post('ttl')) {
			$ttl = NULL;
		}
		else {
			$ttl = $this->input->post('ttl');
		}
		
		// Call the create function
		$query = $this->api->dns->create_dns_address(
			$addr->get_address(),
			$this->input->post('hostname'),
			$this->input->post('zone'),
			$ttl,
			$this->input->post('owner')
		);

        // Check for error
		if($query != "OK") {
			$this->error($query);
		}
		else {
			$aRec = $this->api->dns->get_address_record($addr->get_address());
			self::$addr->set_address_record($aRec);
			return $aRec;
		}
	}
	
	private function _edit(&$obj) {}
	
	private function _delete(&$obj) {}
	
	private function _load_system() {
		// Establish the system and address objects
        try {
            self::$sys = $this->impulselib->get_active_system();
        }
        catch (ObjectNotFoundException $onfE) {
            $this->error($onfE->getMessage());
            return;
        }
	}
	
	private function _load_address($address) {
		#try {
		#	self::$addr = self::$sys->get_address($address);
		#}
		
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
				catch (APIException $apiE) {
					$addr = NULL;
				}
			}
		}
		catch (APIException $apiE) {
			$this->error($apiE->getMessage());
			return;
		}
	}
}

/* End of file dns.php */
/* Location: ./application/controllers/dns.php */
