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
	
	public function zone($zone) {
		// SQL Query
		$sql = "SELECT * FROM api.remove_dns_zone({$this->db->escape($zone)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}

    public function address($address, $zone) {
		// SQL Query
		$sql = "SELECT api.remove_dns_address({$this->db->escape($address)},{$this->db->escape($zone)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);
	}
	
	public function mailserver($hostname, $zone) {
		// SQL Query
		$sql = "SELECT api.remove_dns_mailserver({$this->db->escape($hostname)},{$this->db->escape($zone)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);
	}

	public function nameserver($hostname, $zone) {
		// SQL Query
		$sql = "SELECT api.remove_dns_nameserver({$this->db->escape($hostname)},{$this->db->escape($zone)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);
	}
	
	public function srv($alias, $hostname, $zone) {
		// SQL Query
		$sql = "SELECT api.remove_dns_srv({$this->db->escape($alias)},{$this->db->escape($hostname)},{$this->db->escape($zone)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);
	}

	public function cname($alias, $hostname, $zone) {
		// SQL Query
		$sql = "SELECT api.remove_dns_cname({$this->db->escape($alias)},{$this->db->escape($hostname)},{$this->db->escape($zone)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);
	}
	
	public function text($hostname, $zone, $type) {
		// SQL Query
		$sql = "SELECT api.remove_dns_text({$this->db->escape($hostname)},{$this->db->escape($zone)},{$this->db->escape($type)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);
	}
}
/* End of file api_dns_remove.php */
/* Location: ./application/models/API/DNS/api_dns_remove.php */