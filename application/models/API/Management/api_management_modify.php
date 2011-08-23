<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_management_modify extends ImpulseModel {
	
	public function site_configuration($directive, $value) {
		// SQL Query
		$sql = "SELECT api.modify_site_configuration(
			{$this->db->escape($directive)},
			{$this->db->escape($value)}
		)";
		$query = $this->db->query($sql);
		
		// Check errors
        $this->_check_error($query);
	}
}
/* End of file api_management_modify.php */
/* Location: ./application/models/API/DNS/api_management_modify.php */