<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 *	DNS
 */
class Api_dns extends ImpulseModel {

    /**
     * Constructor
     */
	public function __construct() {
		parent::__construct();
	}

    /**
     * Create a DNS A/AAAA record
     * @param $address      IP address
     * @param $hostname     Hostname of the host
     * @param $zone         Domain name of the record
     * @param $ttl          Time-to-live
     * @param $owner        Owner of the record
     */
    public function create_dns_address($address, $hostname, $zone, $ttl, $owner) {
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
	}
	
	/**
     * Get the DNS address record object for a given address
     * @param $address          The address to get on
     * @return AddressRecord    The object of the record
     */
    public function get_address_record($address) {
		// SQL Query
		$sql = "SELECT * FROM api.get_dns_a({$this->db->escape($address)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		// Generate & return result
        $aRecord = $query->row_array();
        if($query->num_rows() == 1) {
            return new AddressRecord(
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
        elseif($query->num_rows() > 1) {
            throw new AmbiguousTargetException("Multiple address records detected. This indicates a database error. Contact your system administrator.");
        }
        else {
            throw new ObjectNotFoundException("Could not locate DNS address record for address $address");
        }
	}

    /**
     * Get all of the pointer records that resolve to an IP address and return an array of PointerRecord objects
     * @param $address                  The address to search on
     * @return array<PointerRecord>     An array of PointerRecords
     */
    public function get_pointer_records($address) {
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

    /**
     * Get all of the TXT or SPF records that resolve to an IP address and return an array of TxtRecord objects
     * @param $address              The address to search for
     * @return array<TxtRecord>     An array of NsRecords
     */
    public function get_text_records($address) {
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

    /**
     * Get all of the NS records that resolve to an IP address and return an array of NsRecord objects
     * @param $address          The address to search for
     * @return array<NsRecord>  An array of NsRecords
     */
    public function get_ns_records($address) {
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

    /**
     * Get all of the MX records that resolve to an IP address and return an array of MxRecord objects
     * @param $address          The address to search for
     * @return array<MxRecord>  Array of MxRecord objects
     */
    public function get_mx_records($address) {
		// SQL Query
		$sql = "SELECT * FROM api.get_dns_mx({$this->db->escape($address)})";
		$query = $this->db->query($sql);

        // Check error
		$this->_check_error($query);
		
		// Generate and return results
        $mxRecord = $query->row_array();
        if($query->num_rows() == 1) {
            return new MxRecord(
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
		elseif($query->num_rows() > 0) {
            throw new AmbiguousTargetException("Multiple MX records detected. This indicates a database error. Contact your administrator.");
        }
        else {
            throw new ObjectNotFoundException("Could not locate a DNS MX record for address $address");
        }
	}

    /**
     * Get a list of all supported DNS record type
     * @return array<string>    List of all record types
     */
    public function get_record_types() {
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

    /**
     * Get a list of all DNS zones that the current user has access to.
     * @param null $username    The username (or NULL for the default)
     * @return array<string>    A list of all DNS zones
     */
    public function get_dns_zones($username=NULL) {
		// SQL Query
		$sql = "SELECT api.get_dns_zones({$this->db->escape($username)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		// Generate results
        $resultSet = array();
		foreach($query->result_array() as $zone) {
			$resultSet[] = $zone['get_dns_zones'];
		}
		
		// Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("You do not have access to any DNS zones. This could be a problem. Talk to your administrator.");
		}
	}
}

/* End of file api_dns.php */
/* Location: ./application/models/API/api_dns.php */