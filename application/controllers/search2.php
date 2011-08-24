<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Search2 extends ImpulseController {
	
	public function __construct() {
		parent::__construct();
	}
	
	public function index() {
		if($this->input->post('submit')) {
			$this->_error("Search code!");
		}
		
		// Navbar
		$navbar = new Navbar("Search", null, null);
		
		// Form data
		$formdata['ranges'] = $this->api->ip->get->ranges();
		$formdata['zones'] = $this->api->dns->get->zones(NULL);
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		#$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('search/form',$formdata,TRUE);
		$info['title'] = "Search";
		
		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function test() {
		echo "Hi";
	}
}
/* End of file search.php */
/* Location: ./application/controllers/search.php */