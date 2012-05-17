<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_management_remove extends ImpulseModel {
	
	public function site_configuration($directive) {
		// SQL Query
		$sql = "SELECT api.remove_site_configuration({$this->db->escape($directive)})";
		
		// Check errors
        $this->_check_error($query);
	}
}
/* End of file api_management_remove.php */
/* Location: ./application/models/API/DNS/api_management_remove.php */