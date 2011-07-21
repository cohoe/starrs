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
		$navModes = array();
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$viewData['rules'] = self::$addr->get_rules();
		$viewData['deny'] = self::$addr->get_fw_default();
		
		// More view data
		$info['title'] = "Firewall Rules - ".self::$addr->get_address();
		$navbar = new Navbar("Firewall Rules for ".self::$addr->get_address(), $navModes, $navOptions);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('firewall/address', $viewData, TRUE);

		// Load the main view
		$this->load->view('core/main',$info);
	}
}

/* End of file firewall.php */
/* Location: ./application/controllers/firewall.php */