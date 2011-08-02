<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 * IP address information
 */
class Api_ip extends ImpulseModel {

    /**
     * Constructor
     */
	function __construct() {
		parent::__construct();
	}

    /**
     * @return array<IpRange>
     */
	public function get_ranges() {
        // SQL Query
		$sql = "SELECT * FROM api.get_ip_ranges()";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

        // Generate results
        $resultSet = array();
        foreach($query->result_array() as $range) {
            $resultSet[] = new IpRange(
                $range['first_ip'],
                $range['last_ip'],
                $range['use'],
                $range['name'],
                $range['subnet'],
                $range['class'],
                $range['comment'],
                $range['date_created'],
                $range['date_modified'],
                $range['last_modifier']
            );
        }

        // Return results
        if(count($resultSet) > 0) {
            return $resultSet;
        }
        else {
            throw new ObjectNotFoundException("No ranges were found. This indicates a database error. Contact your system administrator");
        }
	}

    /**
     * Get the first available address from an IP range
     * @param $range        The name of the range to pull from
     * @return string       The IP address for you to use
     */
	public function get_address_from_range($range) {
        // SQL query
		$sql = "SELECT api.get_address_from_range({$this->db->escape($range)})";
		$query = $this->db->query($sql);

        // Check errors
        $this->_check_error($query);
        
        // Generate and return result
		return $query->row()->get_address_from_range;
	}

    /**
     * Get the name of the range that an address is contained within
     * @param $address      The address to search on
     * @return              The name of the range
     */
	public function get_address_range($address) {
        // SQL Query
		$sql = "SELECT api.get_address_range({$this->db->escape($address)})";
		$query = $this->db->query($sql);

        // Check errors
        $this->_check_error($query);

        // Generate and return result
		return $query->row()->get_address_range;
	}
	
	public function arp($address) {
		// SQL Query
		$sql = "SELECT api.ip_arp({$this->db->escape($address)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		// Return result
		return $query->row()->ip_arp;
	}
	
	public function ip_in_subnet($address, $subnet) {
		// SQL Query
		$sql = "SELECT api.ip_in_subnet({$this->db->escape($address)}, {$this->db->escape($subnet)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		// Return result
		return $query->row()->ip_in_subnet;
	}
	
	public function get_subnets() {
		// SQL Query
		$sql = "SELECT * FROM api.get_ip_subnets()";
		
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		// Generate results
		$resultSet = array();
		foreach($query->result_array() as $subnet) {
			$sNet = new Subnet(
				$subnet['name'],
				$subnet['subnet'],
				$subnet['zone'],
				$subnet['owner'],
				$subnet['autogen'],
				$subnet['dhcp_enable'],
				$subnet['comment'],
				$subnet['date_created'],
				$subnet['date_modified'],
				$subnet['last_modifier']
			);
			
			try {
				$fwAddresses = $this->api->firewall->get_addresses($sNet->get_subnet());
				if(isset($fwAddresses['primary'])) {
					$sNet->set_firewall_primary($fwAddresses['primary']);
				}
				if(isset($fwAddresses['secondary'])) {
					$sNet->set_firewall_secondary($fwAddresses['secondary']);
				}
			}
			catch (DBException $dbE) {
				$this->_error($dbE->getMessage());
			}
			catch (ObjectNotFoundException $onfE) { }
			
			$resultSet[] = $sNet;
		}
		
		// Return results
        if(count($resultSet) > 0) {
            return $resultSet;
        }
        else {
            throw new ObjectNotFoundException("No Subnets were found. This may or may not be bad. Contact your system administrator");
        }
	}
	
	public function get_subnet($subnet) {
		// SQL Query
		$sql = "SELECT * FROM api.get_ip_subnet({$this->db->escape($subnet)})";
		
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		// Generate results		
		$sNet = new Subnet(
			$query->row()->name,
			$query->row()->subnet,
			$query->row()->zone,
			$query->row()->owner,
			$query->row()->autogen,
			$query->row()->dhcp_enable,
			$query->row()->comment,
			$query->row()->date_created,
			$query->row()->date_modified,
			$query->row()->last_modifier
		);
		
		try {
			$fwAddresses = $this->api->firewall->get_addresses($sNet->get_subnet());
			if(isset($fwAddresses['primary'])) {
				$sNet->set_firewall_primary($fwAddresses['primary']);
			}
			if(isset($fwAddresses['secondary'])) {
				$sNet->set_firewall_secondary($fwAddresses['secondary']);
			}
		}
		catch (DBException $dbE) {
			$this->_error($dbE->getMessage());
		}
		catch (ObjectNotFoundException $onfE) { }
		
		// Return result
		return $sNet;
	}
}

/* End of file api_ip.php */
/* Location: ./application/models/API/api_ip.php */