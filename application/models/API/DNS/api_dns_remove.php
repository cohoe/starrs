<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 *	DNS
 */
class Api_dns_remove extends ImpulseModel {
	
	public function key($keyname) {
		// SQL Query
		$sql = "SELECT * FROM api.remove_dns_key({$this->db->escape($keyname)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
}
/* End of file api_dns_remove.php */
/* Location: ./application/models/API/DNS/api_dns_remove.php */