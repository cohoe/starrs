<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_network_create extends ImpulseModel {
	
	public function switchport($portName, $systemName, $type, $description) {
		// SQL Query
		$sql = "SELECT * FROM api.create_switchport(
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
        // $systemName, $portName, $type, $description, $portState, $adminState, $dateCreated, $dateModified, $lastModifier
        return new NetworkSwitchport(
            $query->row()->system_name,
            $query->row()->port_name,
            $query->row()->type,
            $query->row()->description,
            $query->row()->port_state,
            $query->row()->admin_state,
            $query->row()->date_created,
            $query->row()->date_modified,
            $query->row()->last_modifier
        );
	}
	
	public function switchport_range($prefix, $firstNumber, $lastNumber, $systemName, $type, $description) {
		// SQL Query
		$sql = "SELECT * FROM api.create_switchport_range(
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
			$resultSet[] = new NetworkSwitchport(
                $switchport['system_name'],
				$switchport['port_name'],
                $switchport['type'],
				$switchport['description'],
				$switchport['port_state'],
				$switchport['admin_state'],
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

    public function switchview_settings($systemName, $enable, $roCommunity, $rwCommunity) {
        // SQL Query
		$sql = "SELECT api.create_system_switchview(
			{$this->db->escape($systemName)},
			{$this->db->escape($enable)},
			{$this->db->escape($roCommunity)},
			{$this->db->escape($rwCommunity)}
		)";
		$query = $this->db->query($sql);

		// Check errors
        $this->_check_error($query);
    }
}
/* End of file api_network_create.php */
/* Location: ./application/models/API/Network/api_network_create.php */