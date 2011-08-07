<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_network_remove extends ImpulseModel {
	
	public function switchport($portName, $systemName) {
		// SQL Query
		$sql = "SELECT api.remove_switchport(
			{$this->db->escape($portName)},
			{$this->db->escape($systemName)}
		)";
		$query = $this->db->query($sql);
		
		// Check errors
        $this->_check_error($query);
	}
	
	public function switchport_range($prefix, $firstNumber, $lastNumber, $systemName) {
		// SQL Query
		$sql = "SELECT api.remove_switchport_range(
			{$this->db->escape($prefix)},
			{$this->db->escape($firstNumber)},
			{$this->db->escape($lastNumber)},
			{$this->db->escape($systemName)}
		)";
		$query = $this->db->query($sql);
		
		// Check errors
        $this->_check_error($query);
	}

    public function switchview_settings($systemName) {
        // SQL Query
		$sql = "SELECT api.remove_system_switchview({$this->db->escape($systemName)})";
		$query = $this->db->query($sql);

		// Check errors
        $this->_check_error($query);
    }
	
}
/* End of file api_network_remove.php */
/* Location: ./application/models/Network/Network/api_network_remove.php */