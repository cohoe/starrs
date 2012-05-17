<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_management_create extends ImpulseModel {
	
	public function log_entry($source, $severity, $message) {
		// SQL Query
		$sql = "SELECT api.create_log_entry(
			{$this->db->escape($source)},
			{$this->db->escape($severity)},
			{$this->db->escape($message)}
		)";
        $query = $this->db->query($sql);
		
		// Check errors
        $this->_check_error($query);
	}
	
	public function site_configuration($directive, $value) {
		// SQL Query
		$sql = "SELECT api.create_site_configuration(
			{$this->db->escape($directive)},
			{$this->db->escape($value)}
		)";
        $query = $this->db->query($sql);
		
		// Check errors
        $this->_check_error($query);
	}
}
/* End of file api_management_create.php */
/* Location: ./application/models/API/DNS/api_management_create.php */