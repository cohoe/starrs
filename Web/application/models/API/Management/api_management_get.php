<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_management_get extends ImpulseModel {

	public function current_user() {
        // SQL Query
		$sql = "SELECT api.get_current_user()";
		$query = $this->db->query($sql);

        // Check errors
        $this->_check_error($query);

        // Return result
		return $query->row()->get_current_user;
	}
	
	public function current_user_level() {
        // SQL Query
		$sql = "SELECT api.get_current_user_level()";
		$query = $this->db->query($sql);

        // Check errors
        $this->_check_error($query);

        // Return result
		return $query->row()->get_current_user_level;
	}
	
	public function site_configuration($directive) {
		// SQL Query
		$sql = "SELECT api.get_site_configuration({$this->db->escape($directive)})";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
		
		// Return result
		return $query->row()->get_site_configuration;
	}
	
	public function site_configuration_all() {
		// SQL Query
		$sql = "SELECT * FROM api.get_site_configuration_all()";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
		
		// Return result
		return $query;
	}
}
/* End of file api_management_get.php */
/* Location: ./application/models/API/DNS/api_management_get.php */