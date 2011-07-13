<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Error extends CI_Controller {
	
	public function index() {
		// Information
		$navOptions = array();
		$navbar = new Navbar("Error",FALSE,FALSE,NULL,"/error",$navOptions);
		
		$data['message'] = "Permission Denied";
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('core/permissiondenied',$data,TRUE);
		$info['title'] = "Error";
		
		// Load the main view
		$this->load->view('core/main',$info);
	}	

}
