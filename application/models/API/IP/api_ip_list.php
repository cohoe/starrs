<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 *	IP
 */
class Api_ip_list extends ImpulseModel {
	
	public function owned_subnets($username=NULL) {
		// SQL query
		$sql = "SELECT subnet FROM api.get_ip_subnets({$this->db->escape($username)})";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
		
		$resultSet = array();
		foreach($query->result_array() as $result) {
			$resultSet[] = $result['subnet'];
		}
		
		return $resultSet;
	}
	
	public function other_subnets($username=NULL) {
		// SQL query
		$sql = "SELECT subnet FROM api.get_ip_subnets(NULL) WHERE owner != {$this->db->escape($username)}";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
		
		$resultSet = array();
		foreach($query->result_array() as $result) {
			$resultSet[] = $result['subnet'];
		}
		
		return $resultSet;
	}
	
	public function ranges() {
		// SQL query
		$sql = "SELECT name FROM api.get_ip_ranges()";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
		
		$resultSet = array();
		foreach($query->result_array() as $result) {
			$resultSet[] = $result['name'];
		}
		
		return $resultSet;
	}
}
/* End of file api_ip_list.php */
/* Location: ./application/models/API/IP/api_ip_list.php */