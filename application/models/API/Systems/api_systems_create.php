<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_systems_create extends ImpulseModel {
	
	public function system($systemName,$owner=NULL,$type,$osName,$comment) {
        // SQL Query
		$sql = "SELECT api.create_system(
			{$this->db->escape($systemName)},
			{$this->db->escape($owner)},
			{$this->db->escape($type)},
			{$this->db->escape($osName)},
			{$this->db->escape($comment)})";
		$query = $this->db->query($sql);

        // Check errors
		$this->_check_error($query);
		
		// Return object
		return $this->get_system_data($systemName,false);
	}
	
	public function _interface($systemName, $mac, $interfaceName, $comment) {
        // SQL Query
		$sql = "SELECT api.create_interface(
			{$this->db->escape($systemName)},
			{$this->db->escape($mac)},
			{$this->db->escape($interfaceName)},
			{$this->db->escape($comment)})";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
		
		// Return object
		return $this->get_system_interface_data($mac, false);
	}
	
	public function interface_address($mac, $address, $config, $class, $isprimary, $comment) {
	    // SQL Query
		$sql = "SELECT api.create_interface_address(
			{$this->db->escape($mac)},
			{$this->db->escape($address)},
			{$this->db->escape($config)},
			{$this->db->escape($class)},
			{$this->db->escape($isprimary)},
			{$this->db->escape($comment)}
		)";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
		
		// Return object
		return $this->api->systems->get->system_interface_address($address, false);
	}
}
/* End of file api_systems_create.php */
/* Location: ./application/models/API/Systems/api_systems_create.php */