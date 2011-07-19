<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");
/**
 * 
 */
class Test extends ImpulseController {
	
	public function index() {
		echo "Hello";
		echo $this->api->dhcp->get_dhcp_classes(5);
	}
	
}

/* End of file test.php */
/* Location: ./application/controllers/test.php */