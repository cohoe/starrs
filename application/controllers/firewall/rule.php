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

		if(!(self::$sys instanceof System)) {
			$this->_load_system();
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

        if(preg_match("/metahost/",self::$fwRule->get_source())) {
            $navModes['DELETE'] = "/metahost/rule/delete/".self::$addr->get_address()."/".self::$fwRule->get_transport()."/".self::$fwRule->get_port();
        }
        else {
            $navModes['DELETE'] = "/firewall/rule/delete/".self::$addr->get_address()."/".self::$fwRule->get_transport()."/".self::$fwRule->get_port();
        }

		// Navbar
		$navOptions['Rules'] = "/firewall/rules/view/".self::$addr->get_address();
		$navModes['EDIT'] = "/firewall/rule/edit/".self::$addr->get_address()."/".self::$fwRule->get_transport()."/".self::$fwRule->get_port();
		#$navModes['DELETE'] = "/firewall/rule/delete/".self::$addr->get_address()."/".self::$fwRule->get_transport()."/".self::$fwRule->get_port();

		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$viewData['fwRule'] = self::$fwRule;
		$info['title'] = "Firewall Rule - ".self::$addr->get_address();
		$navbar = new Navbar("Firewall Rule", $navModes, $navOptions);

		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);

		$info['data'] = $this->load->view('firewall/rules/view',$viewData,TRUE);

		// Load the main view
		$this->load->view('core/main',$info);
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

		if(!(self::$sys instanceof System)) {
			$this->_load_system();
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
				$this->api->firewall->remove_standalone_program(self::$fwRule->get_address(),self::$fwRule->get_program_name());
			}
			else {
				$this->api->firewall->remove_standalone_rule(self::$fwRule->get_address(),self::$fwRule->get_port(),self::$fwRule->get_transport());
			}

			// Set the SESSION data
			self::$int->add_address($this->api->systems->get_system_interface_address($address,true));
			self::$sys->add_interface(self::$int);
			$this->impulselib->set_active_system(self::$sys);

			// Move along
			redirect(base_url()."/firewall/rules/view/".self::$addr->get_address(),'location');
		}
		catch (DBException $dbE) {
			$this->_error($dbE->getMessage());
			return;
		}
	}


}
/* End of file rules.php */
/* Location: ./application/controllers/rules.php */