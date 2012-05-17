<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	DNS
 */
class Api_dns_list extends ImpulseModel {

	public function owned_keys($username=NULL) {
		// SQL query
		$sql = "SELECT keyname FROM api.get_dns_keys({$this->db->escape($username)})";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
		
		$resultSet = array();
		foreach($query->result_array() as $result) {
			$resultSet[] = $result['keyname'];
		}
		
		return $resultSet;
	}
	
	public function other_keys($username=NULL) {
		// SQL query
		$sql = "SELECT keyname FROM api.get_dns_keys(NULL) WHERE owner != {$this->db->escape($username)}";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
		
		$resultSet = array();
		foreach($query->result_array() as $result) {
			$resultSet[] = $result['keyname'];
		}
		
		return $resultSet;
	}
	
	public function owned_zones($username=NULL) {
		// SQL query
		$sql = "SELECT zone FROM api.get_dns_zones({$this->db->escape($username)}) WHERE owner = {$this->db->escape($username)}";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
		
		$resultSet = array();
		foreach($query->result_array() as $result) {
			$resultSet[] = $result['zone'];
		}
		
		return $resultSet;
	}
	
	public function other_zones($username=NULL) {
		// SQL query
		$sql = "SELECT zone FROM api.get_dns_zones(NULL) WHERE owner != {$this->db->escape($username)}";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
		
		$resultSet = array();
		foreach($query->result_array() as $result) {
			$resultSet[] = $result['zone'];
		}
		
		return $resultSet;
	}
}
/* End of file api_dns_list.php */
/* Location: ./application/models/API/DNS/api_dns_list.php */