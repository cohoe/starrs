<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Welcome extends ImpulseController {

	public function index() {
		// Navbar
		$navOptions['Quick Start'] = "/system/quickcreate";
		$navbar = new Navbar("IMPULSE", null, $navOptions);
		
		$data['message'] = "Welcome to IMPULSE!";
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('core/success',$data,TRUE);
		$info['title'] = "Welcome";
		$info['help'] = $this->load->view("help/welcome",null,TRUE);		
		
		// Load the main view
		$this->load->view('core/main',$info);
	}
}
/* End of file welcome.php */
/* Location: ./application/controllers/welcome.php */
