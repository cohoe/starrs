<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Rules extends ImpulseController {
	
	public function __construct() {
		parent::__construct();
	}
	
	public function view($address=NULL) {
		if($address==NULL) {
			$this->_error("No address specified");
		}
		$address = rawurldecode($address);
		
		if(!(self::$sys instanceof System)) {
			$this->_load_system($this->api->systems->get->interface_address_system($address));
		}
		if(!(self::$addr instanceof InterfaceAddress)) {
			$this->_load_address($address);
		}
		
		// Navbar
		$navOptions['Overview'] = "/address/view/".rawurlencode(self::$addr->get_address());
		$navOptions['DNS Records'] = "/dns/view/".rawurlencode(self::$addr->get_address());
		$navOptions['Firewall Rules'] = "/firewall/rules/view/".rawurlencode(self::$addr->get_address());
		$navModes['CREATE'] = "/firewall/rules/create/".rawurlencode(self::$addr->get_address());
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
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
		}
		$address = rawurldecode($address);
		
		if(!(self::$sys instanceof System)) {
			$this->_load_system($this->api->systems->get->interface_address_system($address));
		}
		if(!(self::$addr instanceof InterfaceAddress)) {
			$this->_load_address($address);
		}
		if(!(self::$int instanceof NetworkInterface)) {
			$this->_load_interface(self::$addr->get_mac());
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
				self::$sidebar->reload();
				
				// Move along
				redirect(base_url()."firewall/rules/view/".rawurlencode(self::$addr->get_address()),'location');
			}
			catch (DBException $dbE) {
				$this->_error("DB: ".$dbE->getMessage());
			}
			catch (ObjectException $oE) {
				$this->_error("Obj: ".$oE->getMessage());
			}
			catch (ControllerException $cE) {
				$this->_error("Cont: ".$cE->getMessage());
			}
		}
		else {
			// Navbar
			$navModes['CANCEL'] = "/firewall/rules/view/".rawurlencode(self::$addr->get_address());
			
			// Load view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$viewData['transports'] = $this->api->firewall->get->transports();
			$viewData['addr'] = self::$addr;
			$viewData['fwProgs'] = $this->api->firewall->get->programs();
			$viewData['user'] = $this->impulselib->get_username();
			if($this->api->isadmin() == TRUE) {
				$viewData['admin'] = TRUE;
			}
			
			// More view data
			$info['title'] = "Create Standalone Firewall Rule - ".rawurlencode(self::$addr->get_address());
			$navbar = new Navbar("Create Standalone Firewall Rule", $navModes, null);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $this->load->view('firewall/standalone_create',$viewData,true);

			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	public function delete($address=NULL,$transport=NULL,$port=NULL) {
		if($address==NULL) {
			$this->_error("No address specified");
		}
		if($transport==NULL) {
			$this->_error("No transport specified");
		}
		if($port==NULL) {
			$this->_error("No port specified");
		}
		$address = rawurldecode($address);
		
		if(!(self::$sys instanceof System)) {
			$this->_load_system($this->api->systems->get->interface_address_system($address));
		}
		if(!(self::$addr instanceof InterfaceAddress)) {
			$this->_load_address($address);
		}

		try {
			self::$fwRule = self::$addr->get_rule($port,$transport);
		}
		catch (ObjectNotFoundException $onfE) {
			$this->_error($onfE->getMessage());
		}

		try {
			if(self::$fwRule->get_source() == 'standalone-program') {
				$this->api->firewall->remove->standalone_program(self::$fwRule->get_address(),self::$fwRule->get_program_name());
			}
			else {
				$this->api->firewall->remove->standalone_rule(self::$fwRule->get_address(),self::$fwRule->get_port(),self::$fwRule->get_transport());
			}

			// Set the SESSION data
			self::$int->add_address($this->api->systems->get->system_interface_address($address,true));
			self::$sys->add_interface(self::$int);
			$this->impulselib->set_active_system(self::$sys);
			self::$sidebar->reload();

			// Move along
			redirect(base_url()."firewall/view/".rawurlencode(self::$addr->get_address()),'location');
		}
		catch (DBException $dbE) {
			$this->_error($dbE->getMessage());
			return;
		}
	}
	
	private function _create() {
		if($this->input->post('program')) {
			$fwRule = $this->api->firewall->create->standalone_program(
				self::$addr->get_address(),
				$this->input->post('program'),
				$this->input->post('deny'),
				$this->input->post('owner')
			);
		}
		else {
			$fwRule = $this->api->firewall->create->standalone_rule(
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
    
	public function action($address=NULL) {
		if($address==NULL) {
			$this->_error("No address specified");
		}
		$address = rawurldecode($address);
		
		if(!(self::$sys instanceof System)) {
			$this->_load_system($this->api->systems->get->interface_address_system($address));
		}
		if(!(self::$addr instanceof InterfaceAddress)) {
			$this->_load_address($address);
		}
		if(!(self::$int instanceof NetworkInterface)) {
			$this->_load_interface(self::$addr->get_mac());
		}
		
		if($this->input->post('submit')) {
			try {
				self::$addr->set_fw_default($this->input->post('deny'));
				
				// Update our information
				self::$int->add_address(self::$addr);
				self::$sys->add_interface(self::$int);
				$this->impulselib->set_active_system(self::$sys);
				
				// Move along
				redirect(base_url()."firewall/rules/view/".rawurlencode(self::$addr->get_address()),'location');
			}
			catch (DBException $dbE) {
				$this->_error($dbE->getMessage());
			}
		}
		else {
			// Navbar
			$navModes['CANCEL'] = "/firewall/rules/view/".rawurlencode($address);
			
			// Load view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$viewData['addr'] = self::$addr;
			$viewData['user'] = $this->impulselib->get_username();
			if($this->api->isadmin() == TRUE) {
				$viewData['admin'] = TRUE;
			}
			
			// More view data
			$info['title'] = "Modify Default Firewall Action";
			$navbar = new Navbar("Modify Default Firewall Action", $navModes, null);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $this->load->view('firewall/default',$viewData,true);

			// Load the main view
			$this->load->view('core/main',$info);
		}

	}
}
/* End of file rules.php */
/* Location: ./application/controllers/firewall/rules.php */
