<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 *	DNS
 */
class Api_dns_modify extends ImpulseModel {
	
	public function key($keyname, $field, $value) {
		// SQL Query
		$sql = "SELECT api.modify_dns_key(
			{$this->db->escape($keyname)},
			{$this->db->escape($field)},
			{$this->db->escape($value)}
		)";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
	public function zone($zone, $field, $value) {
		// SQL Query
		$sql = "SELECT api.modify_dns_zone(
			{$this->db->escape($zone)},
			{$this->db->escape($field)},
			{$this->db->escape($value)}
		)";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}

    public function address($address, $zone, $field, $newValue) {
		// SQL Query
		$sql = "SELECT api.modify_dns_address({$this->db->escape($address)}, {$this->db->escape($zone)}, {$this->db->escape($field)}, {$this->db->escape($newValue)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);
	}
	
	public function mailserver($hostname, $zone, $field, $newValue) {
		// SQL Query
		$sql = "SELECT api.modify_dns_mailserver({$this->db->escape($hostname)}, {$this->db->escape($zone)}, {$this->db->escape($field)}, {$this->db->escape($newValue)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);
	}

	public function nameserver($hostname, $zone, $field, $newValue) {
		// SQL Query
		$sql = "SELECT api.modify_dns_nameserver({$this->db->escape($hostname)}, {$this->db->escape($zone)}, {$this->db->escape($field)}, {$this->db->escape($newValue)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);
	}

	public function srv($alias, $zone, $field, $newValue) {
		// SQL Query
		$sql = "SELECT api.modify_dns_srv({$this->db->escape($alias)}, {$this->db->escape($zone)}, {$this->db->escape($field)}, {$this->db->escape($newValue)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);
	}

	public function cname($alias, $zone, $field, $newValue) {
		// SQL Query
		$sql = "SELECT api.modify_dns_cname({$this->db->escape($alias)}, {$this->db->escape($zone)}, {$this->db->escape($field)}, {$this->db->escape($newValue)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);
	}

	public function text($hostname, $zone, $type, $field, $newValue) {
		// SQL Query
		$sql = "SELECT api.modify_dns_text({$this->db->escape($hostname)}, {$this->db->escape($zone)}, {$this->db->escape($type)}, {$this->db->escape($field)}, {$this->db->escape($newValue)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);
	}
}
/* End of file api_dns_modify.php */
/* Location: ./application/models/API/DNS/api_dns_modify.php */