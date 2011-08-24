<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Metahost_rule extends ImpulseController {

	public static $fwRule;

	public function __construct() {
		parent::__construct();
	}

	public function view($metahostName=NULL,$transport=NULL,$port=NULL) {
		if($metahostName==NULL) {
			$this->_error("No metahost specified");
		}
		if($transport==NULL) {
			$this->_error("No transport specified");
		}
		if($port==NULL) {
			$this->_error("No port specified");
		}

		if(!(self::$mHost instanceof Metahost)) {
			$this->_load_metahost($metahostName);
		}

		try {
			self::$fwRule = self::$mHost->get_rule($port,$transport);
		}
		catch (ObjectNotFoundException $onfE) {
			$this->_error($onfE->getMessage());
		}

		$navModes['DELETE'] = "/firewall/metahost_rule/delete/".rawurlencode(self::$mHost->get_name())."/".rawurlencode(self::$fwRule->get_transport())."/".rawurlencode(self::$fwRule->get_port());
		if(self::$fwRule->get_mode() != 'PROGRAM') {
			$navModes['EDIT'] = "/firewall/metahost_rule/edit/".rawurlencode(self::$mHost->get_name())."/".rawurlencode(self::$fwRule->get_transport())."/".rawurlencode(self::$fwRule->get_port());
		}

		// Navbar
		$navOptions['Overview'] = '/firewall/metahosts/view/'.rawurlencode(self::$mHost->get_name());
		$navOptions['Members'] = '/firewall/metahost_members/view/'.rawurlencode(self::$mHost->get_name());
		$navOptions['Rules'] = '/firewall/metahost_rules/view/'.rawurlencode(self::$mHost->get_name());

		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$viewData['fwRule'] = self::$fwRule;
		$info['title'] = "Firewall Metahost Rule";
		$navbar = new Navbar("Firewall Metahost Rule", $navModes, $navOptions);

		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('firewall/standalone_view',$viewData,TRUE);

		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function edit($metahostName=NULL,$transport=NULL,$port=NULL) {
		if($metahostName==NULL) {
			$this->_error("No metahost specified");
		}
		if($transport==NULL) {
			$this->_error("No transport specified");
		}
		if($port==NULL) {
			$this->_error("No port specified");
		}

		if(!(self::$mHost instanceof Metahost)) {
			$this->_load_metahost($metahostName);
		}
		
		$metahostName = rawurldecode($metahostName);
		$transport = rawurldecode($transport);
		$port = rawurldecode($port);

		try {
			self::$fwRule = self::$mHost->get_rule($port,$transport);
		}
		catch (ObjectNotFoundException $onfE) {
			$this->_error($onfE->getMessage());
		}
		
		// Information is there. Execute the edit
		if($this->input->post('submit')) {
			try {
				$this->_edit();
				self::$sidebar->reload();
				redirect(base_url()."firewall/metahost_rule/view/".rawurlencode(self::$mHost->get_name())."/".rawurlencode(self::$fwRule->get_transport())."/".rawurlencode(self::$fwRule->get_port()),'location');
			}
			catch (ControllerException $cE) {
				$this->_error($cE->getMessage());
			}
		}
		else {
			// Navbar
			$navModes['CANCEL'] = "/firewall/metahost_rule/view/".rawurlencode($metahostName)."/".rawurlencode($transport)."/".rawurlencode($port);
			$navbar = new Navbar("Edit Metahost Rule", $navModes, null);
			
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
			$form['mHosts'] = $this->api->firewall->get->metahosts($form['user']);
			$form['mHostName'] = self::$mHost->get_name();
			
			// Continue loading view data
			$info['data'] = $this->load->view('metahosts/rule_edit',$form,TRUE);
			$info['title'] = "Edit Metahost Rule";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	public function delete($metahostName=NULL,$transport=NULL,$port=NULL) {
		if($metahostName==NULL) {
			$this->_error("No metahost specified");
		}
		if($transport==NULL) {
			$this->_error("No transport specified");
		}
		if($port==NULL) {
			$this->_error("No port specified");
		}
		
		if(!(self::$mHost instanceof Metahost)) {
			$this->_load_metahost($metahostName);
		}

		try {
			self::$fwRule = self::$mHost->get_rule($port,$transport);
		}
		catch (ObjectNotFoundException $onfE) {
			$this->_error($onfE->getMessage());
		}

		try {
			if(self::$fwRule->get_source() == 'metahost-program') {
				$this->api->firewall->remove->metahost_program_rule(self::$mHost->get_name(),self::$fwRule->get_program_name());
			}
			else {
				$this->api->firewall->remove->metahost_rule(self::$mHost->get_name(),self::$fwRule->get_port(),self::$fwRule->get_transport());
			}

			// Move along
			self::$sidebar->reload();
			redirect(base_url()."firewall/metahost_rules/view/".rawurlencode(self::$mHost->get_name()),'location');
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
		
		if($err != "") {
			throw new ControllerException($err);
		}
	}
}
/* End of file rules.php */
/* Location: ./application/controllers/metahost/rules.php */