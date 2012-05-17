<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");
/**
 * 
 */
class Test extends ImpulseController {
	
	public function index() {
		echo "Hello";
		
		echo $this->impulselib->test();
		echo $this->api->get_username();
		
		$navbar = new Navbar("Testing",null,null);
		$this->load->view('core/navbar',array('navbar'=>$navbar));
		
		#$this->remove_system('bvlisofwks003');
	}
	
	public function remove_system($name) {
		// SQL Query
		$sql = "SELECT api.get_system_interfaces('$name')";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
	protected function _check_error($query) {
		if($this->db->_error_number() > 0) {
			throw new DBException($this->db->_error_message());
		}
		if($this->db->_error_message() != "") {
			throw new DBException($this->db->_error_message());
		}
		if($query->num_rows() == 0) {
			throw new ObjectNotFoundException("Object not found!");
		}
	}
	
}

/* End of file test.php */
/* Location: ./application/controllers/test.php */