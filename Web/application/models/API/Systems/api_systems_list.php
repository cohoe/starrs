<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_systems_list extends ImpulseModel {
	
	public function owned_systems($username=NULL) {
		// SQL query
		$sql = "SELECT system_name FROM api.get_systems({$this->db->escape($username)})";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
		
		$resultSet = array();
		foreach($query->result_array() as $result) {
			$resultSet[] = $result['system_name'];
		}
		
		return $resultSet;
	}
	
	public function other_systems($username=NULL) {
		// SQL query
		$sql = "SELECT system_name FROM api.get_systems(NULL) WHERE owner != {$this->db->escape($username)}";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
		
		$resultSet = array();
		foreach($query->result_array() as $result) {
			$resultSet[] = $result['system_name'];
		}
		
		return $resultSet;
	}
	
	public function interfaces($systemName) {
		// SQL query
		$sql = "SELECT name,mac FROM api.get_system_interfaces({$this->db->escape($systemName)})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
		
		$resultSet = array();
		foreach($query->result_array() as $result) {
			$resultSet[$result['name']] = $result['mac'];
		}
		
		return $resultSet;
	}
	
	public function interface_addresses($mac) {
		// SQL query
		$sql = "SELECT address FROM api.get_system_interface_addresses({$this->db->escape($mac)})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
		
		$resultSet = array();
		foreach($query->result_array() as $result) {
			$resultSet[] = $result['address'];
		}
		
		return $resultSet;
	}
	
	public function dynamic_interface_addresses($mac) {
		// SQL query
		$sql = "SELECT address FROM api.get_system_interface_addresses({$this->db->escape($mac)}) WHERE address << cidr((SELECT api.get_site_configuration('DYNAMIC_SUBNET')))";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
		
		$resultSet = array();
		foreach($query->result_array() as $result) {
			$resultSet[] = $result['address'];
		}
		
		return $resultSet;
	}
}
/* End of file api_systems_list.php */
/* Location: ./application/models/API/Systems/api_systems_list.php */