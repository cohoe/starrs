<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 *	IP
 */
class Api_ip_modify extends ImpulseModel {
	
	public function range($name, $field, $value) {
		// SQL Query
		$sql = "SELECT api.modify_ip_range(
			{$this->db->escape($name)},
			{$this->db->escape($field)},
			{$this->db->escape($value)}
		)";
		#echo $sql;
		#exit;
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
	public function subnet($subnet, $field, $value) {
		// SQL Query
		$sql = "SELECT api.modify_ip_subnet(
			{$this->db->escape($subnet)},
			{$this->db->escape($field)},
			{$this->db->escape($value)}
		)";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
}
/* End of file api_ip_modify.php */
/* Location: ./application/models/API/IP/api_ip_modify.php */
