<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_systems_remove extends ImpulseModel {
	
	public function system($systemName) {
		// SQL Query
		$sql = "SELECT api.remove_system({$this->db->escape($systemName)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
	public function _interface($mac) {
		// SQL Query
		$sql = "SELECT api.remove_interface({$this->db->escape($mac)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
	public function interface_address($address) {
		// SQL Query
		$sql = "SELECT api.remove_interface_address({$this->db->escape($address)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
}
/* End of file api_systems_remove.php */
/* Location: ./application/models/Systems/Systems/api_systems_remove.php */