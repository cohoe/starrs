<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");
require_once(APPPATH . "controllers/firewall/rules.php");

class Rule extends ImpulseController {

	public static $fwRule;

	public function __construct() {
		parent::__construct();
	}

	public function view($address=NULL,$transport=NULL,$port=NULL) {
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


        if(preg_match("/^standalone-/",self::$fwRule->get_source())) {
            $navModes['DELETE'] = "/firewall/rule/delete/".rawurlencode(self::$addr->get_address())."/".rawurlencode(self::$fwRule->get_transport())."/".rawurlencode(self::$fwRule->get_port());
            $navModes['EDIT'] = "/firewall/rule/edit/".rawurlencode(self::$addr->get_address())."/".rawurlencode(self::$fwRule->get_transport())."/".rawurlencode(self::$fwRule->get_port());
            $title = "Standalone Rule";
        }
        else {
            $navModes = array();
            $title = "Firewall Metahost Rule";
        }

		// Navbar
		$navOptions['Rules'] = "/firewall/rules/view/".rawurlencode(self::$addr->get_address());
		$navbar = new Navbar($title, $navModes, $navOptions);

		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "$title - ".self::$addr->get_address();
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		
		$viewData['fwRule'] = self::$fwRule;
		$info['data'] = $this->load->view('firewall/standalone_view',$viewData,TRUE);

		// Load the main view
		$this->load->view('core/main',$info);
	}

	public function edit($address=NULL,$transport=NULL,$port=NULL) {
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
		if(!(self::$int instanceof NetworkInterface)) {
			$this->_load_interface(self::$addr->get_mac());
		}
		
		$address = rawurldecode($address);
		$transport = rawurldecode($transport);
		$port = rawurldecode($port);

		try {
			self::$fwRule = self::$addr->get_rule($port,$transport);
		}
		catch (ObjectNotFoundException $onfE) {
			$this->_error($onfE->getMessage());
		}
		
		// Information is there. Execute the edit
		if($this->input->post('submit')) {
			try {
				$this->_edit();
				
				// Update our information
				self::$addr = $this->api->systems->get->system_interface_address($address,TRUE);
				self::$int->add_address(self::$addr);
				self::$sys->add_interface(self::$int);
				$this->impulselib->set_active_system(self::$sys);
				self::$sidebar->reload();
				redirect(base_url()."firewall/rule/view/".rawurlencode(self::$fwRule->get_address())."/".rawurlencode(self::$fwRule->get_transport())."/".rawurlencode(self::$fwRule->get_port()),'location');
			}
			catch (ControllerException $cE) {
				$this->_error($cE->getMessage());
			}
		}
		else {
			// Navbar
			$navModes['CANCEL'] = "/firewall/rule/view/".rawurlencode($address)."/".rawurlencode($transport)."/".rawurlencode($port);
			$navbar = new Navbar("Edit Firewall Rule", $navModes, null);
				
			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Get the preset form data for dropdown lists and things
			$form['fwRule'] = self::$fwRule;
			$form['user'] = $this->impulselib->get_username();
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}
			$form['transports'] = $this->api->firewall->get->transports();
			$form['addrs'] = $this->api->systems->get->owned_addresses($form['user']);
			
			// Continue loading view data
			$info['data'] = $this->load->view('firewall/standalone_edit',$form,TRUE);
			$info['title'] = "Edit Firewall Rule";
			
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
		if(!(self::$int instanceof NetworkInterface)) {
			$this->_load_interface(self::$addr->get_mac());
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
			redirect(base_url()."firewall/rules/view/".rawurlencode(self::$addr->get_address()),'location');
		}
		catch (DBException $dbE) {
			$this->_error($dbE->getMessage());
		}
	}
	
	private function _edit() {
		// The error return message
		$err = "";
		
		// Check for which field was modified
		if(self::$fwRule->get_deny() != $this->input->post('deny')) {
			try { self::$fwRule->set_deny($this->input->post('deny')); }
			catch (DBException $dbE) { $err .= $dbE->getMessage(); }
		}
		if(self::$fwRule->get_port() != $this->input->post('port')) {
			try { self::$fwRule->set_port($this->input->post('port')); }
			catch (DBException $dbE) { $err .= $dbE->getMessage(); }
		}
		if(self::$fwRule->get_transport() != $this->input->post('transport')) {
			try { self::$fwRule->set_transport($this->input->post('transport')); }
			catch (DBException $dbE) { $err .= $dbE->getMessage(); }
		}
		if(self::$fwRule->get_comment() != $this->input->post('comment')) {
			try { self::$fwRule->set_comment($this->input->post('comment')); }
			catch (DBException $dbE) { $err .= $dbE->getMessage(); }
		}
		if(self::$fwRule->get_address() != $this->input->post('address')) {
			try { self::$fwRule->set_address($this->input->post('address')); }
			catch (DBException $dbE) { $err .= $dbE->getMessage(); }
		}
		if(self::$fwRule->get_owner() != $this->input->post('owner')) {
			try { self::$fwRule->set_owner($this->input->post('owner')); }
			catch (DBException $dbE) { $err .= $dbE->getMessage(); }
		}
		
		if($err != "") {
			throw new ControllerException($err);
		}
	}
}
/* End of file rules.php */
/* Location: ./application/controllers/rules.php */
