<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");
/**
 * 
 */
class Resources extends ImpulseController {
	
	public function __construct() {
		parent::__construct();
	}
	
	public function index() {
		// Navbar
		$navOptions['Keys'] = "/resources/keys";
		$navOptions['Zones'] = "/resources/zones";
		$navOptions['Subnets'] = "/resources/subnets";
		$navOptions['Ranges'] = "/resources/ranges";
	
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['title'] = "Resources";
		$navbar = new Navbar("Resources", null, $navOptions);
		
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('resources/list',null,TRUE);

		// Load the main view
		$this->load->view('core/main',$info);
	}
}
/* End of file resources.php */
/* Location: ./application/controllers/resources.php */