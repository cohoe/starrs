<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_network_modify extends ImpulseModel {
	
	public function switchport($systemName, $portName, $field, $value) {
		// SQL Query
		$sql = "SELECT api.modify_network_switchport(
			{$this->db->escape($systemName)},
			{$this->db->escape($portName)},
			{$this->db->escape($field)},
			{$this->db->escape($value)}
		)";
        $query = $this->db->query($sql);
		
		// Check errors
        $this->_check_error($query);
	}

    public function switchview_settings($systemName, $field, $newValue) {
        // SQL Query
		$sql = "SELECT api.modify_system_switchview(
		    {$this->db->escape($systemName)},
		    {$this->db->escape($field)},
		    {$this->db->escape($newValue)}
		)";
		$query = $this->db->query($sql);

		// Check errors
        $this->_check_error($query);
    }
	
	public function switchport_admin_state($systemName, $portName, $state) {
        // SQL Query
		$sql = "SELECT api.modify_switchport_admin_state(
		    {$this->db->escape($systemName)},
		    {$this->db->escape($portName)},
		    {$this->db->escape($state)}
		)";
		$query = $this->db->query($sql);

		// Check errors
        $this->_check_error($query);
    }
}
/* End of file api_network_modify.php */
/* Location: ./application/models/API/Network/api_network_modify.php */