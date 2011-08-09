<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");
/**
 * 
 */
class Admin extends ImpulseController {
	
	public function __construct() {
		parent::__construct();
		if($this->api->isadmin() == false) {
			$this->_error("Permission denied. You are not an IMPULSE administrator");
		}
	}
	
	public function index() {
		// Navbar
		$navOptions['Site Configuration'] = "/admin/configuration/view/site";
	
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "IMPULSE Administration";
		$navbar = new Navbar("Administration", null, $navOptions);
		
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->_warning("Objects in mirror may be closer than they appear!");

		// Load the main view
		$this->load->view('core/main',$info);
	}
}
/* End of file admin.php */
/* Location: ./application/controllers/admin.php */