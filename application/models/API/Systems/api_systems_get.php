<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_systems_get extends ImpulseModel {
	
	public function systems($owner=null) {
        // SQL Query
        $sql = "SELECT api.get_systems({$this->db->escape($owner)})";
        $query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

        // Generate results
        $resultSet = array();
        foreach($query->result_array() as $system) {
            $resultSet[] = $system['get_systems'];
        }

        // Return results
        if(count($resultSet) > 0) {
            return $resultSet;
        }
        else {
            throw new ObjectNotFoundException("No systems found!");
        }
    }
	
	public function system($systemName, $complete=false) {
        // SQL Query
		$sql = "SELECT * FROM api.get_system_data({$this->db->escape($systemName)})";
		$query = $this->db->query($sql);

        // Check errors
        $this->_check_error($query);
		if($query->num_rows() > 1) {
			throw new AmbiguousTargetException("More than one system matches '{$systemName}'");
		}
		
		// Generate results
		$systemData = $query->row_array();
		$sys = new System(
			$systemData['system_name'],
			$systemData['owner'],
			$systemData['comment'],
			$systemData['type'],
			$systemData['os_name'],
			$systemData['renew_date'],
			$systemData['date_created'],
			$systemData['date_modified'],
			$systemData['last_modifier']);
		
		// Generate a complete object
		if($complete == true) {
			// Grab the interfaces that the system has
			foreach($this->get_system_interfaces($systemName, $complete) as $interface) {
				$sys->add_interface($interface);
			} 
		}
		
		// Return result
		return $sys;
	}
	
	public function system_interfaces($systemName, $complete=false) {
        // SQL Query
		$sql = "SELECT * FROM api.get_system_interfaces({$this->db->escape($systemName)})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
        
		// Generate results
		$resultSet = array();
		foreach($query->result_array() as $row) {
			// Create the interface
			$int = new NetworkInterface(
				$row['mac'], 
				$row['comment'], 
				$row['system_name'], 
				$row['name'],
				$row['date_created'], 
				$row['date_modified'], 
				$row['last_modifier']
			);

            // Generate a complete object
			if($complete == true) {
				$addrs = $this->get_interface_addresses($row['mac'],$complete);
				foreach($addrs as $addr) {
					$int->add_address($addr);
				}
			}
			
			// Add the machine to the result set
			$resultSet[] = $int;
		}

        // Return results
        if(count($resultSet) > 0) {
            return $resultSet;
        }
        else {
            throw new ObjectNotFoundException("No interfaces found!");
        }
	}
	
	public function system_interface_data($mac, $complete=false) {
		// SQL Query
		$sql = "SELECT * FROM api.get_system_interface_data({$this->db->escape($mac)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		if($query->num_rows() > 1) {
			throw new AmbiguousTargetException("More than one interface matches '{$mac}'. This indicates a database error. Contact your system administrator.");
		}
		
		// Generate results
		$result = $query->row_array();
		$int = new NetworkInterface(
			$result['mac'],
			$result['comment'],
			$result['system_name'],
			$result['name'],
			$result['date_created'],
			$result['date_modified'],
			$result['last_modifier']
		);
		
		if($complete == true) {
			$addrs = $this->get_system_interface_addresses($result['mac'],$complete);
			foreach($addrs as $addr) {
				$int->add_address($addr);
			}
		}
		
		// Return result
		return $int;
	}
	
	public function system_interface_addresses($mac, $complete=false) {
		// SQL Query
		$sql = "SELECT * FROM api.get_system_interface_addresses({$this->db->escape($mac)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		// Generate results
		$resultSet = array();
		foreach($query->result_array() as $row) {
			$addr = new InterfaceAddress(
				$row['address'], 
				$row['class'], 
				$row['config'], 
				$row['mac'], 
				$row['renew_date'], 
				$row['isprimary'],
				$row['comment'], 
				$row['date_created'], 
				$row['date_modified'], 
				$row['last_modifier']
			);

            // If we are building all information about the system, do all this stuff
            if($complete == true) {
                // Load firewall rules
				try {
					$fwRules = $this->api->firewall->get->address_rules($row['address']);
					foreach($fwRules as $fwRule) {
						$addr->add_firewall_rule($fwRule);
					}
				}
				catch (ObjectNotFoundException $onfE) {}

				// Load DNS pointer records
				try {
					$pointerRecords = $this->api->dns->get->pointer_records($row['address']);
					foreach ($pointerRecords as $pointerRecord) {
						$addr->add_pointer_record($pointerRecord);
					}
				}
				catch (ObjectNotFoundException $onfE) {}

				// Load DNS text records
				try {
					$textRecords = $this->api->dns->get->text_records($row['address']);
					foreach ($textRecords as $textRecord) {
						$addr->add_text_record($textRecord);
					}
				}
				catch (ObjectNotFoundException $onfE) {}
				
				// Load DNS nameserver records
				try {
					$nsRecords = $this->api->dns->get->ns_records($row['address']);
					foreach ($nsRecords as $nsRecord) {
						$addr->add_ns_record($nsRecord);
					}
				}
				catch (ObjectNotFoundException $onfE) {}

				// Load DNS mailserver records
				try {
					$mxRecord = $this->api->dns->get->mx_records($row['address']);
					$addr->add_mx_record($mxRecord);
				}
				catch (ObjectNotFoundException $onfE) {}
            }

            // Add the address to the array
            $resultSet[] = $addr;
		}

        // Return results
        if(count($resultSet) > 0) {
            return $resultSet;
        }
        else {
            throw new ObjectNotFoundException("No addresses found!");
        }
	}
	
	public function system_interface_address($address, $complete=false) {
		// SQL Query
		$sql = "SELECT * FROM api.get_system_interface_address({$this->db->escape($address)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		if($query->num_rows() > 1) {
			throw new AmbiguousTargetException("More than one interface matches '{$mac}'. This indicates a database error. Contact your system administrator.");
		}
		
		// Generate results
		$row = $query->row_array();
		$addr = new InterfaceAddress(
				$row['address'], 
				$row['class'], 
				$row['config'], 
				$row['mac'], 
				$row['renew_date'], 
				$row['isprimary'],
				$row['comment'], 
				$row['date_created'], 
				$row['date_modified'], 
				$row['last_modifier']
		);

		// If we are building all information about the system, do all this stuff
		if($complete == true) {
			// Load firewall rules
			try {
				$fwRules = $this->api->firewall->get_address_rules($row['address']);
				#$fwRules = $this->api->firewall->load_address_rules($row['address']);
				foreach($fwRules as $fwRule) {
					$addr->add_firewall_rule($fwRule);
				}
			}
			catch (ObjectNotFoundException $onfE) {}


			// Load DNS pointer records
			try {	
				$pointerRecords = $this->api->dns->get->pointer_records($row['address']);
				foreach ($pointerRecords as $pointerRecord) {
					$addr->add_pointer_record($pointerRecord);
				}
			}
			catch (ObjectNotFoundException $onfE) {}

			// Load DNS text records
			try {
				$textRecords = $this->api->dns->get->text_records($row['address']);
				foreach ($textRecords as $textRecord) {
					$addr->add_text_record($textRecord);
				}
			}
			catch (ObjectNotFoundException $onfE) {}

			// Load DNS nameserver records
			try {
				$nsRecords = $this->api->dns->get->ns_records($row['address']);
				foreach ($nsRecords as $nsRecord) {
					$addr->add_ns_record($nsRecord);
				}
			}
			catch (ObjectNotFoundException $onfE) {}

			// Load DNS mailserver records
			try {
				$mxRecord = $this->api->dns->get->mx_records($row['address']);
				$addr->add_mx_record($mxRecord);
			}
			catch (ObjectNotFoundException $onfE) {}
		}

        // Return results
		return $addr;
	}
	
	public function owned_addresses($username=NULL) {
		// SQL Query
		$sql = "SELECT * FROM api.get_owned_interface_addresses({$this->db->escape($username)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		// Generate results
		$resultSet = array();
		foreach($query->result_array() as $row) {
			$resultSet[] = new InterfaceAddress(
				$row['address'], 
				$row['class'], 
				$row['config'], 
				$row['mac'], 
				$row['renew_date'], 
				$row['isprimary'],
				$row['comment'], 
				$row['date_created'], 
				$row['date_modified'], 
				$row['last_modifier']
			);
		}
		
		// Return results
        if(count($resultSet) > 0) {
            return $resultSet;
        }
        else {
            throw new ObjectNotFoundException("No addresses found!");
        }
	}
	
	public function system_types() {
		// SQL Query
		$sql = "SELECT api.get_system_types()";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		// Generate results
		$types = array();
		foreach($query->result_array() as $result) {
			$types[] = $result['get_system_types'];
		}

		// Return results
		return $types;
	}

	public function operating_systems() {
		// SQL Query
		$sql = "SELECT api.get_operating_systems()";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		// Generate results
		$oss = array();
		foreach($query->result_array() as $os) {
			$oss[] = $os['get_operating_systems'];
		}

		// Return results
		return $oss;
	}

	// @todo: Move these to statistics
	public function os_distribution() {
		$sql = "SELECT * FROM api.get_os_distribution()";
		$query = $this->db->query($sql);
		return $query->result_array();
	}

	public function os_family_distribution() {
		$sql = "SELECT * FROM api.get_os_family_distribution()";
		$query = $this->db->query($sql);
		return $query->result_array();
	}
	
	public function interface_owner($int) {
		// SQL Query
		$sql = "SELECT api.get_interface_owner('{$int->get_mac()}')";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		// Return results
		return $query->row()->get_interface_owner;
	}
	
	public function interface_address_system($address) {
		// SQL Query
		$sql = "SELECT api.get_interface_address_system({$this->db->escape($address)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		// Return results
		if($query->num_rows() == 1) {
			return $query->row()->get_interface_address_system;
		}
		if($query->num_rows() > 1) {
			throw new AmbiguousTargetException("More than one match for '{$address}'. This indicates a database error. Contact your system administrator.");
		}
	}
}
/* End of file api_systems_get.php */
/* Location: ./application/models/API/Systems/api_systems_get.php */