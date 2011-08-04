<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_network_create extends ImpulseModel {
	
	public function switchport($portName, $systemName, $type, $description) {
		// SQL Query
		$sql = "SELECT api.create_switchport(
			{$this->db->escape($portName)},
			{$this->db->escape($systemName)},
			{$this->db->escape($type)},
			{$this->db->escape($description)}
		)";
		$query = $this->db->query($sql);
		
		// Check errors
        $this->_check_error($query);
		
		if($query->num_rows() > 1) {
            throw new AmbiguousTargetException("The API returned more than one switchport. This is a problem. Contact your system administrator");
        }
		
		// Generate and return results
        return new Switchport(
            $query->row()->port_name,
            $query->row()->description,
            $query->row()->type,
            $query->row()->attached_mac,
            $query->row()->system_name,
            $query->row()->date_created,
            $query->row()->date_modified,
            $query->row()->last_modifier
        );
	}
	
	public function switchport_range($prefix, $firstNumber, $lastNumber, $systemName, $type, $description) {
		// SQL Query
		$sql = "SELECT api.create_switchport_range(
			{$this->db->escape($prefix)},
			{$this->db->escape($firstNumber)},
			{$this->db->escape($lastNumber)},
			{$this->db->escape($systemName)},
			{$this->db->escape($type)},
			{$this->db->escape($description)}
		)";
		$query = $this->db->query($sql);
		
		// Check errors
        $this->_check_error($query);
		
		// Generate and return results
		$resultSet = array();
		foreach ($query->result_array() as $switchport) {
			$resultSet[] = new Switchport(
				$switchport['port_name'],
				$switchport['description'],
				$switchport['type'],
				$switchport['attached_mac'],
				$switchport['system_name'],
				$switchport['date_created'],
				$switchport['date_modified'],
				$switchport['last_modifier']
			);
		}
		
		// Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No switchports returned. This is a big problem. Talk to your administrator.");
		}
	}
}
/* End of file api_network_create.php */
/* Location: ./application/models/API/Network/api_network_create.php */