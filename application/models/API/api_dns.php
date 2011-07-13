<?php
/**
 *
 */
class Api_dns extends CI_Model {

    /**
     *
     */
	public function __construct() {
		parent::__construct();
	}
	
	/**
     * Get the DNS address record object for a given address
     * @param $address          The address to get on
     * @return \AddressRecord   The object of the record
     */
    public function get_address_record($address) {
		$sql = "SELECT * FROM api.get_dns_a({$this->db->escape($address)})";
		$query = $this->db->query($sql);
        $info = $query->row_array();

        // Establish and return the record object
        if($query->num_rows() == 1) {
            return new AddressRecord(
                $info['hostname'],
                $info['zone'],
                $info['address'],
                $info['type'],
                $info['ttl'],
                $info['owner'],
                $info['date_created'],
                $info['date_modified'],
                $info['last_modifier']
            );
        }
        else {
            return null;
        }
	}

    /**
     * Get all of the pointer records that resolve to an IP address and return an array of PointerRecord objects
     * @param $address              The address to search on
     * @return array<PointerRecord> An array of PointerRecords
     */
    public function get_pointer_records($address) {
		$sql = "SELECT * FROM api.get_dns_pointers({$this->db->escape($address)})";
		$query = $this->db->query($sql);

        // Declare the array of record objects
        $recordSet = array();

        // Loop through the results, instantiating all of them
        foreach ($query->result_array() as $pointerRecord) {
            $recordSet[] = new PointerRecord(
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

        // Return the array of objects
        return $recordSet;
	}

    /**
     * Get all of the TXT or SPF records that resolve to an IP address and return an array of TxtRecord objects
     * @param $address          The address to search for
     * @return array<TxtRecord> An array of NsRecords
     */
    public function get_txt_records($address) {
		$sql = "SELECT * FROM api.get_dns_txt({$this->db->escape($address)})";
		$query = $this->db->query($sql);

        // Declare the array of text objects
        $recordSet = array();

        // Loop through the results, instantiating all of them
        foreach ($query->result_array() as $txtRecord) {
            $recordSet[] = new TxtRecord(
                $txtRecord['hostname'],
                $txtRecord['zone'],
                $txtRecord['address'],
                $txtRecord['type'],
                $txtRecord['ttl'],
                $txtRecord['owner'],
                $txtRecord['text'],
                $txtRecord['date_created'],
                $txtRecord['date_modified'],
                $txtRecord['last_modifier']
            );
        }

        // Return the array of objects
        return $recordSet;
	}

    /**
     * Get all of the NS records that resolve to an IP address and return an array of NsRecord objects
     * @param $address          The address to search for
     * @return array<NsRecord>  An array of NsRecords
     */
    public function get_ns_records($address) {
		$sql = "SELECT * FROM api.get_dns_ns({$this->db->escape($address)})";
		$query = $this->db->query($sql);

        // Declare the array of text objects
        $recordSet = array();

        // Loop through the results, instantiating all of them
        foreach ($query->result_array() as $nsRecord) {
            $recordSet[] = new NsRecord(
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

        // Return the array of objects
        return $recordSet;
	}

    /**
     * Get all of the MX records that resolve to an IP address and return an array of MxRecord objects
     * @param $address          The address to search for
     * @return array<MxRecord>  Array of MxRecord objects
     * @todo: Make this only return one result since there can only ever be one MX record for an address
     */
    public function get_mx_records($address) {
		$sql = "SELECT * FROM api.get_dns_mx({$this->db->escape($address)})";
		$query = $this->db->query($sql);

        // Declare the array of text objects
        $recordSet = array();

        // Loop through the results, instantiating all of them
        foreach ($query->result_array() as $mxRecord) {
            $recordSet[] = new MxRecord(
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

        // Return the array of objects
        return $recordSet;
	}
	
	/**
     * Get the DNS FQDN of a given IP address if it exists
     * @param $address  The address to search on
     * @return string   The FQDN of the address (or NULL if none)
     */
    public function get_ip_fqdn($address) {
		$sql = "SELECT hostname||'.'||zone AS fqdn FROM dns.a WHERE address = '$address'";
		$query = $this->db->query($sql);
		#$arr = $query->result_array();
		#echo $arr;
		if($query->row()) {
			return $query->row()->fqdn;
		}
		else {
			return null;
		}
	}
}