<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	DNS
 */
class Api_dns_get extends ImpulseModel {

	public function mx_records($address) {
		// SQL Query
		$sql = "SELECT * FROM api.get_dns_mx({$this->db->escape($address)})";
		$query = $this->db->query($sql);

        // Check error
		$this->_check_error($query);

		// Generate and return results
        $resultSet = array();
        foreach ($query->result_array() as $mxRecord) {
            $resultSet[] = new MxRecord(
                $mxRecord['hostname'],
                $mxRecord['zone'],
                $mxRecord['address'],
                $mxRecord['type'],
                $mxRecord['ttl'],
                $mxRecord['owner'],
                $mxRecord['preference'],
                $mxRecord['date_created'],
                $mxRecord['date_modified'],
                $mxRecord['last_modifier']
            );
        }
		
        // Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No MX records found for address $address");
		}
	}
	
	public function ns_records($address) {
		// SQL Query
		$sql = "SELECT * FROM api.get_dns_ns({$this->db->escape($address)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		// Generate results
        $resultSet = array();
        foreach ($query->result_array() as $nsRecord) {
            $resultSet[] = new NsRecord(
                $nsRecord['hostname'],
                $nsRecord['zone'],
                $nsRecord['address'],
                $nsRecord['type'],
                $nsRecord['ttl'],
                $nsRecord['owner'],
                $nsRecord['isprimary'],
                $nsRecord['date_created'],
                $nsRecord['date_modified'],
                $nsRecord['last_modifier']
            );
        }

        // Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No NS records found for address $address");
		}
	}
	
	public function text_records($address) {
		// SQL Query
		$sql = "SELECT * FROM api.get_dns_text({$this->db->escape($address)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

        // Generate results
        $resultSet = array();
        foreach ($query->result_array() as $textRecord) {
            $resultSet[] = new TextRecord(
                $textRecord['hostname'],
                $textRecord['zone'],
                $textRecord['address'],
                $textRecord['type'],
                $textRecord['ttl'],
                $textRecord['owner'],
                $textRecord['text'],
                $textRecord['date_created'],
                $textRecord['date_modified'],
                $textRecord['last_modifier']
            );
        }

        // Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
        else {
            throw new ObjectNotFoundException("No text records found for address $address");
        }
	}
	
	public function pointer_records($address) {
		// SQL Query
		$sql = "SELECT * FROM api.get_dns_pointers({$this->db->escape($address)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);


        // Generate results
        $resultSet = array();
        foreach ($query->result_array() as $pointerRecord) {
            $resultSet[] = new PointerRecord(
                $pointerRecord['hostname'],
                $pointerRecord['zone'],
                $pointerRecord['address'],
                $pointerRecord['type'],
                $pointerRecord['ttl'],
                $pointerRecord['owner'],
                $pointerRecord['alias'],
                $pointerRecord['extra'],
                $pointerRecord['date_created'],
                $pointerRecord['date_modified'],
                $pointerRecord['last_modifier']
            );
        }

        // Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No pointer records found for address $address");
		}
	}
    
    public function address_records($address) {
		// SQL Query
		$sql = "SELECT * FROM api.get_dns_a({$this->db->escape($address)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		// Generate & return result
        $resultSet = array();
        foreach ($query->result_array() as $aRecord) {
            $resultSet[] = new AddressRecord(
                $aRecord['hostname'],
                $aRecord['zone'],
                $aRecord['address'],
                $aRecord['type'],
                $aRecord['ttl'],
                $aRecord['owner'],
                $aRecord['date_created'],
                $aRecord['date_modified'],
                $aRecord['last_modifier']
            );
        }

		// Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No address records found for address $address");
		}
	}

    public function record_types() {
		// SQL Query
		$sql = "SELECT api.get_record_types()";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		// Generate results
        $resultSet = array();
		foreach($query->result_array() as $recordType) {
			$resultSet[] = $recordType['get_record_types'];
		}

		// Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No DNS record types found. This is a big problem. Talk to your administrator.");
		}
	}

	public function zones($username=NULL) {
		// SQL Query
		$sql = "SELECT * FROM api.get_dns_zones({$this->db->escape($username)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		// Generate results
        $resultSet = array();
		foreach($query->result_array() as $zone) {
			$resultSet[] = new DnsZone(
				$zone['zone'],
				$zone['keyname'],
				$zone['forward'],
				$zone['shared'],
				$zone['owner'],
				$zone['comment'],
				$zone['date_created'],
				$zone['date_modified'],
				$zone['last_modifier']
			);
		}

		// Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("You do not have access to any DNS zones. This could be a problem. Talk to your administrator.");
		}
	}

	public function zone($zone) {
		// SQL Query
		$sql = "SELECT * FROM api.get_dns_zone({$this->db->escape($zone)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		if($query->num_rows() > 1) {
			throw new AmbiguousTargetException("Multiple zones found? This is a database error. Contact your system administrator");
		}

		// Generate results
		$dnsZone = new DnsZone(
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

		// Return results
		return $dnsZone;
	}

    public function keys($username=NULL) {
		// SQL Query
		$sql = "SELECT * FROM api.get_dns_keys({$this->db->escape($username)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		// Generate results
		$resultSet = array();
		foreach($query->result_array() as $key) {
			$resultSet[] = new DnsKey(
				$key['keyname'],
				$key['key'],
				$key['owner'],
				$key['comment'],
				$key['date_created'],
				$key['date_modified'],
				$key['last_modifier']
			);
		}

		// Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("You do not have access to any DNS keys. This could be a problem. Talk to your administrator.");
		}
	}

	public function key($keyname) {
		// SQL Query
		$sql = "SELECT * FROM api.get_dns_key({$this->db->escape($keyname)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		if($query->num_rows() > 1) {
			throw new AmbiguousTargetException("Multiple keys found? This is a database error. Contact your system administrator");
		}

		// Generate results
		$dnsKey = new DnsKey(
			$query->row()->keyname,
			$query->row()->key,
			$query->row()->owner,
			$query->row()->comment,
			$query->row()->date_created,
			$query->row()->date_modified,
			$query->row()->last_modifier
		);

		// Return results
		return $dnsKey;
	}
	
	public function address_record($address, $zone=NULL) {
		// SQL Query
		$sql = "SELECT * FROM api.get_dns_a({$this->db->escape($address)}, {$this->db->escape($zone)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);

		if($query->num_rows() > 1) {
			throw new AmbiguousTargetException("Multiple A records found for this zone? This is a database error. Contact your system administrator");
		}

		// Generate results
		$addressRecord = new AddressRecord(
			$query->row()->hostname,
			$query->row()->zone,
			$query->row()->address,
			$query->row()->type,
			$query->row()->ttl,
			$query->row()->owner,
			$query->row()->date_created,
			$query->row()->date_modified,
			$query->row()->last_modifier
		);

		// Return result
		return $addressRecord;
	}
}
/* End of file api_dns_get.php */
/* Location: ./application/models/API/DNS/api_dns_get.php */
