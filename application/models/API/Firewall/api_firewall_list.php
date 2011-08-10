<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_firewall_list extends ImpulseModel {
	
	public function owned_metahosts($username=NULL) {
		// SQL query
		$sql = "SELECT name FROM api.get_firewall_metahosts({$this->db->escape($username)})";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
		
		$resultSet = array();
		foreach($query->result_array() as $result) {
			$resultSet[] = $result['name'];
		}
		
		return $resultSet;
	}
	
	public function other_metahosts($username=NULL) {
		// SQL query
		$sql = "SELECT name FROM api.get_firewall_metahosts(NULL) WHERE owner != {$this->db->escape($username)}";
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
/* End of file api_firewall_list.php */
/* Location: ./application/models/API/Firewall/api_firewall_list.php */