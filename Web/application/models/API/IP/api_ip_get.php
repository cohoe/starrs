<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 *	IP
 */
class Api_ip_get extends ImpulseModel {
	
	public function address_from_range($range) {
        // SQL query
		$sql = "SELECT api.get_address_from_range({$this->db->escape($range)})";
		$query = $this->db->query($sql);

        // Check errors
        $this->_check_error($query);
        
        // Generate and return result
		return $query->row()->get_address_from_range;
	}
	
	// @todo: Get subnet addresses (for the lulz)
	
	// @todo: Get range addresses (also for the lulz)
	
	public function address_range($address) {
        // SQL Query
		$sql = "SELECT api.get_address_range({$this->db->escape($address)})";
		$query = $this->db->query($sql);

        // Check errors
        $this->_check_error($query);

        // Generate and return result
		return $query->row()->get_address_range;
	}
	
	public function ranges() {
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
	
	public function range($name) {
        // SQL Query
		$sql = "SELECT * FROM api.get_ip_range({$this->db->escape($name)})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

		if($query->num_rows() > 1) {
			throw new AmbiguousTargetException("Multiple results returned by API. Contact your system administrator");
		}
		return new IpRange(
			$query->row()->first_ip,
			$query->row()->last_ip,
			$query->row()->use,
			$query->row()->name,
			$query->row()->subnet,
			$query->row()->class,
			$query->row()->comment,
			$query->row()->date_created,
			$query->row()->date_modified,
			$query->row()->last_modifier
		);
	}
	
	public function subnets($username) {
		// SQL Query
		$sql = "SELECT * FROM api.get_ip_subnets({$this->db->escape($username)})";
		
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
				$fwAddresses = $this->api->firewall->get->addresses($sNet->get_subnet());
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
	
	public function subnet($subnet) {
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
			$fwAddresses = $this->api->firewall->get->addresses($sNet->get_subnet());
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
	
	public function uses() {
		// SQL Query
		$sql = "SELECT api.get_ip_range_uses()";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		// Generate results
		$resultSet = array();
		foreach($query->result_array() as $use) {
			$resultSet[] = $use['get_ip_range_uses'];
		}

		// Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No IP range uses found.");
		}
	}
}
/* End of file api_ip_get.php */
/* Location: ./application/models/API/IP/api_ip_get.php */