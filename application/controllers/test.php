<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Test extends CI_Controller {
	
	public function index() {
		#$this->load->model('Api');
		#$this->api->intialize('benrr101');
		#$this->api->intialize('titsmagee');
		$this->api->test("hello");
	}	

	public function classtest() {
		$class = new InterfaceObject(1,2,3,4,5,6);
	}
}
