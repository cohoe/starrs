<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_systems_modify extends ImpulseModel {
	
	public function system($systemName, $field, $newValue) {
		// SQL Query
		$sql = "SELECT api.modify_system({$this->db->escape($systemName)}, {$this->db->escape($field)}, {$this->db->escape($newValue)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
	public function _interface($mac, $field, $newValue) {
		// SQL Query
		$sql = "SELECT api.modify_interface({$this->db->escape($mac)}, {$this->db->escape($field)}, {$this->db->escape($newValue)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
	public function interface_address($address, $field, $newValue) {
		// SQL Query
		$sql = "SELECT api.modify_interface_address({$this->db->escape($address)}, {$this->db->escape($field)}, {$this->db->escape($newValue)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
}
/* End of file api_systems_modify.php */
/* Location: ./application/models/API/Systems/api_systems_modify.php */
