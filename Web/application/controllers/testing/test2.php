<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Test extends IMPULSE_Controller {
	
	public function index() {
		$navModes['CREATE'] = "test/create";
		$navModes['EDIT'] = "test/edit";
		$navModes['DELETE'] = "test/delete";
		$navModes['CANCEL'] = "";
		$navOptions = array("OS Distribution"=>'os_distribution',"OS Family Distribution"=>'os_family_distribution');
		$navbar = new Navbar("Testing Bar", $navModes, $navOptions);
		
		echo link_tag("/css/mockup/main.css");
		$this->load->view('core/navbar',array("navbar"=>$navbar));
		$this->error("test");
	}
}
