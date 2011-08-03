<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 *	DNS
 */
class Api_dns_modify extends ImpulseModel {
	
	public function key($keyname, $field, $value) {
		// SQL Query
		$sql = "SELECT * FROM api.modify_dns_key(
			{$this->db->escape($keyname)},
			{$this->db->escape($field)},
			{$this->db->escape($value)}
		)";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		if($query->num_rows() > 1) {
			throw new APIException("The database returned more than one key. Contact your system administrator");
		}
		
		// Return object
		return new DnsKey(
			$query->row()->keyname,
			$query->row()->key,
			$query->row()->owner,
			$query->row()->comment,
			$query->row()->date_created,
			$query->row()->date_modified,
			$query->row()->last_modifier
		);
	}
}
/* End of file api_dns_modify.php */
/* Location: ./application/models/API/DNS/api_dns_modify.php */