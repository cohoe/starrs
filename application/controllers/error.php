<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Error extends ImpulseController {
	
	public function index() {
		$this->_error("Error testing!");
	}

}
/* End of file error.php */
/* Location: ./application/controllers/error.php */