<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 *	IP
 */
class Api_ip_remove extends ImpulseModel {
	
	public function subnet($subnet) {
		// SQL Query
		$sql = "SELECT api.remove_ip_subnet({$this->db->escape($subnet)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
	public function range($name) {
		// SQL Query
		$sql = "SELECT api.remove_ip_range({$this->db->escape($name)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
}
/* End of file api_ip_remove.php */
/* Location: ./application/models/API/IP/api_ip_remove.php */