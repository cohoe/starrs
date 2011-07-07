<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Demo extends CI_Controller {
	
	public function index() {
		$skin = "grid";
		echo link_tag("css/$skin/full/main.css");
		$this->load->view('demo/elements');
	}	
}