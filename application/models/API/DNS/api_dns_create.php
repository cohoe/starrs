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
	
	public function zone($zone, $keyname, $forward, $shared, $owner, $comment) {
		// SQL Query
		$sql = "SELECT * FROM api.create_dns_zone(
			{$this->db->escape($zone)},
			{$this->db->escape($keyname)},
			{$this->db->escape($forward)},
			{$this->db->escape($shared)},
			{$this->db->escape($owner)},
			{$this->db->escape($comment)}
		)";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		if($query->num_rows() > 1) {
			throw new APIException("The database returned more than one zone. Contact your system administrator");
		}
		
		// Return object
		return new DnsZone(
			$query->row()->zone,
			$query->row()->keyname,
			$query->row()->forward,
			$query->row()->shared,
			$query->row()->owner,
			$query->row()->comment,
			$query->row()->date_created,
			$query->row()->date_modified,
			$query->row()->last_modifier
		);
	}

     public function address($address, $hostname, $zone, $ttl, $owner) {
		// SQL Query
		$sql = "SELECT api.create_dns_address(
			{$this->db->escape($address)},
			{$this->db->escape($hostname)},
			{$this->db->escape($zone)},
			{$this->db->escape($ttl)},
			{$this->db->escape($owner)}
		)";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		// Return object
		return $this->get_address_record($address);
	}
	
	public function mailserver($hostname, $zone, $preference, $ttl, $owner) {
		// SQL Query
		$sql = "SELECT api.create_dns_mailserver(
			{$this->db->escape($hostname)},
			{$this->db->escape($zone)},
			{$this->db->escape($preference)},
			{$this->db->escape($ttl)},
			{$this->db->escape($owner)}
		)";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		// Return object
		$record = $this->get_mx_records($this->resolve($hostname, $zone, 4));
		return $record;
	}

    public function nameserver($hostname, $zone, $isprimary, $ttl, $owner) {
		// SQL Query
		$sql = "SELECT api.create_dns_nameserver(
			{$this->db->escape($hostname)},
			{$this->db->escape($zone)},
			{$this->db->escape($isprimary)},
			{$this->db->escape($ttl)},
			{$this->db->escape($owner)}
		)";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		// Return object
		foreach($this->get_ns_records($this->resolve($hostname, $zone, 4)) as $record) {
			if($record->get_isprimary() == $isprimary) {
				return $record;
			}
		}
	}
	
	public function srv($alias, $hostname, $zone, $priority, $weight, $port, $ttl, $owner) {
		// SQL Query
		$sql = "SELECT api.create_dns_srv(
			{$this->db->escape($alias)},
			{$this->db->escape($hostname)},
			{$this->db->escape($zone)},
			{$this->db->escape($priority)},
			{$this->db->escape($weight)},
			{$this->db->escape($port)},
			{$this->db->escape($ttl)},
			{$this->db->escape($owner)}
		)";

		echo $sql;
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		// Return object
		foreach($this->get_pointer_records($this->resolve($hostname, $zone, 4)) as $record) {
			if($record->get_alias() == $alias && $record->get_type() == "SRV") {
				return $record;
			}
		}
	}

	public function cname($alias, $hostname, $zone, $ttl, $owner) {
		// SQL Query
		$sql = "SELECT api.create_dns_cname(
			{$this->db->escape($alias)},
			{$this->db->escape($hostname)},
			{$this->db->escape($zone)},
			{$this->db->escape($ttl)},
			{$this->db->escape($owner)}
		)";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		// Return object
		foreach($this->get_pointer_records($this->resolve($hostname, $zone, 4)) as $record) {
			if($record->get_alias() == $alias && $record->get_type() == "CNAME") {
				return $record;
			}
		}
	}

	public function text($hostname, $zone, $text, $type, $ttl, $owner) {
		// SQL Query
		$sql = "SELECT api.create_dns_text(
			{$this->db->escape($hostname)},
			{$this->db->escape($zone)},
			{$this->db->escape($text)},
			{$this->db->escape($type)},
			{$this->db->escape($ttl)},
			{$this->db->escape($owner)}
		)";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		// Return object
		foreach($this->get_text_records($this->resolve($hostname, $zone, 4)) as $record) {
			if($record->get_text() == $text && $record->get_type() == $type) {
				return $record;
			}
		}
	}
}
/* End of file api_dns_create.php */
/* Location: ./application/models/API/DNS/api_dns_create.php */