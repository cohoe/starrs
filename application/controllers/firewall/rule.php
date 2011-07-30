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


        if(preg_match("/standalone/",self::$fwRule->get_source())) {
            $navModes['DELETE'] = "/metahost/rules/delete/".self::$fwRule->get_metahost_name()."/".self::$fwRule->get_transport()."/".self::$fwRule->get_port();
            $navModes['EDIT'] = "/metahost/rule/edit/".self::$fwRule->get_metahost_name()."/".self::$fwRule->get_transport()."/".self::$fwRule->get_port();
            $title = "Firewall Rule";
        }
        else {
            #$navModes['DELETE'] = "/firewall/rule/delete/".self::$addr->get_address()."/".self::$fwRule->get_transport()."/".self::$fwRule->get_port();
            #$navModes['EDIT'] = "/firewall/rule/edit/".self::$addr->get_address()."/".self::$fwRule->get_transport()."/".self::$fwRule->get_port();
            $navModes = array();
            $title = "Firewall Metahost Rule";
        }

		// Navbar
		$navOptions['Rules'] = "/firewall/rules/view/".self::$addr->get_address();

		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$viewData['fwRule'] = self::$fwRule;
		$info['title'] = "$title - ".self::$addr->get_address();
		$navbar = new Navbar($title, $navModes, $navOptions);

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
		}
	}
}
/* End of file rules.php */
/* Location: ./application/controllers/rules.php */