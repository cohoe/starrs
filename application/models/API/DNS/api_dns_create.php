<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 *	DNS
 */
class Api_dns_create extends ImpulseModel {
	
	public function key($keyname, $key, $owner, $comment) {
		// SQL Query
		$sql = "SELECT * FROM api.create_dns_key(
			{$this->db->escape($keyname)},
			{$this->db->escape($key)},
			{$this->db->escape($owner)},
			{$this->db->escape($comment)}
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
/* End of file api_dns_create.php */
/* Location: ./application/models/API/DNS/api_dns_create.php */