<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 *	DHCP Modify
 */
class Api_dhcp_modify extends ImpulseModel {

	public function _class($name, $field, $newValue) {
		// SQL Query
		$sql = "SELECT api.modify_dhcp_class(
			{$this->db->escape($name)},
			{$this->db->escape($field)},
			{$this->db->escape($newValue)}
		)";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
	public function class_option($class, $option, $value, $field, $newValue) {
		// SQL Query
		$sql = "SELECT api.modify_dhcp_class_option(
			{$this->db->escape($class)},
			{$this->db->escape($option)},
			{$this->db->escape($value)},
			{$this->db->escape($field)},
			{$this->db->escape($newValue)}
		)";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
	public function subnet_option($subnet, $option, $value, $field, $newValue) {
		// SQL Query
		$sql = "SELECT api.modify_dhcp_subnet_option(
			{$this->db->escape($subnet)},
			{$this->db->escape($option)},
			{$this->db->escape($value)},
			{$this->db->escape($field)},
			{$this->db->escape($newValue)}
		)";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
	public function range_option($range, $option, $value, $field, $newValue) {
		// SQL Query
		$sql = "SELECT api.modify_dhcp_range_option(
			{$this->db->escape($range)},
			{$this->db->escape($option)},
			{$this->db->escape($value)},
			{$this->db->escape($field)},
			{$this->db->escape($newValue)}
		)";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
	public function global_option($option, $value, $field, $newValue) {
		// SQL Query
		$sql = "SELECT api.modify_dhcp_global_option(
			{$this->db->escape($option)},
			{$this->db->escape($value)},
			{$this->db->escape($field)},
			{$this->db->escape($newValue)}
		)";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
}
/* End of file api_dhcp_modify.php */
/* Location: ./application/models/API/DHCP/api_dhcp_modify.php */