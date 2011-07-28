<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Firewall extends ImpulseController {
	
	public function __construct() {
		parent::__construct();
	}
	
	public function view($address=NULL) {
		if($address==NULL) {
			$this->_error("No address specified");
			return;
		}
		
		if(!(self::$sys instanceof System)) {
			$this->_load_system();
		}
		if(!(self::$addr instanceof InterfaceAddress)) {
			$this->_load_address($address);
		}
		
		// Navbar
		$navOptions['Overview'] = "/addresses/view/".self::$addr->get_address();
		$navOptions['DNS Records'] = "/dns/view/".self::$addr->get_address();
		$navOptions['Firewall Rules'] = "/firewall/view/".self::$addr->get_address();
		$navModes['CREATE'] = "/firewall/create/".self::$addr->get_address();
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$viewData['rules'] = self::$addr->get_rules();
		$viewData['deny'] = self::$addr->get_fw_default();
		$viewData['addr'] = self::$addr;
		
		// More view data
		$info['title'] = "Firewall Rules - ".self::$addr->get_address();
		$navbar = new Navbar("Firewall Rules for ".self::$addr->get_address(), $navModes, $navOptions);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('firewall/address', $viewData, TRUE);

		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function create($address=NULL) {
		if($address==NULL) {
			$this->_error("No address specified");
			return;
		}
		
		if(!(self::$sys instanceof System)) {
			$this->_load_system();
		}
		if(!(self::$addr instanceof InterfaceAddress)) {
			$this->_load_address($address);
		}
		
		
		if($this->input->post('submit')) {
			// Create the record
			try {
				$fwRule = $this->_create();
				// Add it to the address
				self::$addr->add_firewall_rule($fwRule);
				
				// Update our information
				self::$int->add_address(self::$addr);
				self::$sys->add_interface(self::$int);
				$this->impulselib->set_active_system(self::$sys);
				
				// Move along
				redirect(base_url()."/firewall/view/".self::$addr->get_address(),'location');
			}
			catch (DBException $dbE) {
				$this->_error("DB: ".$dbE->getMessage());
				return;
			}
			catch (ObjectException $oE) {
				$this->_error("Obj: ".$dbE->getMessage());
				return;
			}
			catch (ControllerException $cE) {
				$this->_error("Cont: ".$cE->getMessage());
				return;
			}
		}
		else {
			// Navbar
			$navModes['CANCEL'] = "/firewall/view/".self::$addr->get_address();
			
			// Load view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$viewData['transports'] = $this->api->firewall->get_transports();
			$viewData['addr'] = self::$addr;
			$viewData['fwProgs'] = $this->api->firewall->get_programs();
			$viewData['user'] = $this->impulselib->get_username();
			if($this->api->isadmin() == TRUE) {
				$viewData['admin'] = TRUE;
			}
			
			// More view data
			$info['title'] = "Create Standalone Firewall Rule - ".self::$addr->get_address();
			$navbar = new Navbar("Create Standalone Firewall Rule", $navModes, null);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $this->load->view('firewall/rules/create',$viewData,true);

			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	public function edit($address=NULL) {
		if($address==NULL) {
			$this->_error("No address specified");
			return;
		}
		
		if(!(self::$sys instanceof System)) {
			$this->_load_system();
		}
		if(!(self::$addr instanceof InterfaceAddress)) {
			$this->_load_address($address);
		}
		
		echo "EDIT!";
	}
	
	public function delete($address=NULL) {
		if($address==NULL) {
			$this->_error("No address specified");
			return;
		}
		
		if(!(self::$sys instanceof System)) {
			$this->_load_system();
		}
		if(!(self::$addr instanceof InterfaceAddress)) {
			$this->_load_address($address);
		}
		
		echo "DELETE!";
	}
	
	private function _create() {
		if($this->input->post('program')) {
			$fwRule = $this->api->firewall->create_firewall_rule_program(
				self::$addr->get_address(),
				$this->input->post('program'),
				$this->input->post('deny'),
				$this->input->post('owner')
			);
		}
		else {
			$fwRule = $this->api->firewall->create_firewall_rule(
				self::$addr->get_address(),
				$this->input->post('port'),
				$this->input->post('transport'),
				$this->input->post('deny'),
				$this->input->post('owner'),
				$this->input->post('comment')
			);
		}
		
		return $fwRule;
	}
}

/* End of file firewall.php */
/* Location: ./application/controllers/firewall.php */