<?php
/**
 * @throws AmbiguousTargetException|DBException|ObjectNotFoundException
 *
 */
class API_Systems extends ImpulseModel {
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

	public function __construct() {
		parent::__construct();
	}
	
	////////////////////////////////////////////////////////////////////////
	// CREATE FUNCTIONS
	
	/**
	 * Create a system in the database
	 * @param	string	$systemName	The name of the system to create
	 * @param	string	$owner		The owning username
	 * @param	string	$type		The type of system (server, desktop, etc)
	 * @param	string	$osName		The name of the operating system
	 * @param	string	$comment	A comment on the system
	 */
	public function create_system($systemName,$owner=NULL,$type,$osName,$comment) {
        // SQL Query
		$sql = "SELECT api.create_system(
			{$this->db->escape($systemName)},
			{$this->db->escape($owner)},
			{$this->db->escape($type)},
			{$this->db->escape($osName)},
			{$this->db->escape($comment)})";
		$query = $this->db->query($sql);

        // Check errors
		$this->_check_error($query);
		
		// Return object
		return $this->get_system_data($systemName,false);
	}

    /**
     * @throws DBException
     * @param $systemName
     * @param $mac
     * @param $interfaceName
     * @param $comment
     * @return string
     */
	public function create_interface($systemName, $mac, $interfaceName, $comment) {
        // SQL Query
		$sql = "SELECT api.create_interface(
			{$this->db->escape($systemName)},
			{$this->db->escape($mac)},
			{$this->db->escape($interfaceName)},
			{$this->db->escape($comment)})";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
		
		// Return object
		return $this->get_system_interface_data($mac, false);
	}

    /**
     * @throws DBException
     * @param $mac
     * @param $address
     * @param $config
     * @param $class
     * @param $isprimary
     * @param $comment
     * @return string
     */
	public function create_interface_address($mac, $address, $config, $class, $isprimary, $comment) {
	    // SQL Query
		$sql = "SELECT api.create_interface_address(
			{$this->db->escape($mac)},
			{$this->db->escape($address)},
			{$this->db->escape($config)},
			{$this->db->escape($class)},
			{$this->db->escape($isprimary)},
			{$this->db->escape($comment)}
		)";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
		
		// Return object
		return $this->api->systems->get_system_interface_address($address, false);
	}
	
	
	////////////////////////////////////////////////////////////////////////
	// GET FUNCTIONS

    /**
     * @param null $owner
     * @return array
     */
	public function get_systems($owner=null) {
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
	
	/**
	 * Looks up the given system in the database and creates an object to
	 * represent it.
	 * @param	string	$systemName	The name of the system to lookup
	 * @param	bool	$complete	Whether to lookup interfaces,
	 * 								addresses, etc and add them to the system
	 * @throws	AmbiguousTargetException	Thrown when more than one system
	 * 										matches the given input
	 * @throws	ObjectNotFoundException		Thrown when no system was found
	 * @throws	DBException					Thrown if the db shit the bed
	 * @return	System				The system desired
	 */
	public function get_system_data($systemName, $complete=false) {
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
	
	/**
	 * Look up the interfaces that match up with a given system. Process each
	 * interface into an interface object and then return it as an array.
	 * @param	string	$systemName	The name of the system to lookup
	 * @param	bool	$complete	Whether to lookup the addresses associated
	 * 								with each interfaces
	 * @throws	ObjectNotFoundException		Thrown if the interface was not found
	 * @throws	DBException					Thrown if the database shit the bed
	 * @return	array<Interface>	An array of interface objects associated with the system
	 */
	public function get_system_interfaces($systemName, $complete=false) {
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
	
	public function get_system_interface_data($mac, $complete=false) {
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

    /**
     * Query the database for the interface addresses associated with the given
	 * MAC address
     * @param $mac                      The MAC address of the interface to search on
     * @param bool $complete            Are we making a complete system
     * @throws	DBException				Thrown if the database shit the bed
     * @return array<InterfaceAddress>  An array of InterfaceAddress objects
     */
    public function get_system_interface_addresses($mac, $complete=false) {
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
					$fwRules = $this->api->firewall->get_address_rules($row['address']);
					#$fwRules = $this->api->firewall->load_address_rules($row['address']);
					foreach($fwRules as $fwRule) {
						$addr->add_firewall_rule($fwRule);
					}
				}
				catch (ObjectNotFoundException $onfE) {}

				// Load DNS pointer records
				try {
					$pointerRecords = $this->api->dns->get_pointer_records($row['address']);
					foreach ($pointerRecords as $pointerRecord) {
						$addr->add_pointer_record($pointerRecord);
					}
				}
				catch (ObjectNotFoundException $onfE) {}

				// Load DNS text records
				try {
					$textRecords = $this->api->dns->get_text_records($row['address']);
					foreach ($textRecords as $textRecord) {
						$addr->add_text_record($textRecord);
					}
				}
				catch (ObjectNotFoundException $onfE) {}
				
				// Load DNS nameserver records
				try {
					$nsRecords = $this->api->dns->get_ns_records($row['address']);
					foreach ($nsRecords as $nsRecord) {
						$addr->add_ns_record($nsRecord);
					}
				}
				catch (ObjectNotFoundException $onfE) {}

				// Load DNS mailserver records
				try {
					$mxRecord = $this->api->dns->get_mx_records($row['address']);
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
	
	public function get_system_interface_address($address, $complete=false) {
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
				$pointerRecords = $this->api->dns->get_pointer_records($row['address']);
				foreach ($pointerRecords as $pointerRecord) {
					$addr->add_pointer_record($pointerRecord);
				}
			}
			catch (ObjectNotFoundException $onfE) {}

			// Load DNS text records
			try {
				$textRecords = $this->api->dns->get_text_records($row['address']);
				foreach ($textRecords as $textRecord) {
					$addr->add_text_record($textRecord);
				}
			}
			catch (ObjectNotFoundException $onfE) {}

			// Load DNS nameserver records
			try {
				$nsRecords = $this->api->dns->get_ns_records($row['address']);
				foreach ($nsRecords as $nsRecord) {
					$addr->add_ns_record($nsRecord);
				}
			}
			catch (ObjectNotFoundException $onfE) {}

			// Load DNS mailserver records
			try {
				$mxRecord = $this->api->dns->get_mx_records($row['address']);
				$addr->add_mx_record($mxRecord);
			}
			catch (ObjectNotFoundException $onfE) {}
		}

        // Return results
		return $addr;
	}
	
	public function get_owned_addresses($username=NULL) {
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

    /**
     * @return array
     */
	public function get_system_types() {
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

    /**
     * @return array
     */
	public function get_operating_systems() {
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

    /**
     * @return
     */
	public function get_os_distribution() {
		$sql = "SELECT * FROM api.get_os_distribution()";
		$query = $this->db->query($sql);
		return $query->result_array();
	}

    /**
     * @return
     */
	public function get_os_family_distribution() {
		$sql = "SELECT * FROM api.get_os_family_distribution()";
		$query = $this->db->query($sql);
		return $query->result_array();
	}
	
	public function get_interface_owner($int) {
		// SQL Query
		$sql = "SELECT api.get_interface_owner('{$int->get_mac()}')";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		// Return results
		return $query->row()->get_interface_owner;
	}
	
	public function get_interface_address_system($address) {
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
	
	////////////////////////////////////////////////////////////////////////
	// MODIFY FUNCTIONS

    /**
     * @throws DBException
     * @param $systemName
     * @param $field
     * @param $newValue
     * @return string
     */
	public function modify_system($systemName, $field, $newValue) {
		// SQL Query
		$sql = "SELECT api.modify_system({$this->db->escape($systemName)}, {$this->db->escape($field)}, {$this->db->escape($newValue)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
	public function modify_interface($mac, $field, $newValue) {
		// SQL Query
		$sql = "SELECT api.modify_interface({$this->db->escape($mac)}, {$this->db->escape($field)}, {$this->db->escape($newValue)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
	public function modify_interface_address($address, $field, $newValue) {
		// SQL Query
		$sql = "SELECT api.modify_interface_address({$this->db->escape($address)}, {$this->db->escape($field)}, {$this->db->escape($newValue)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
	////////////////////////////////////////////////////////////////////////
	// REMOVE FUNCTIONS

    /**
     * @throws DBException
     * @param $sys
     * @return string
     */
	public function remove_system($sys) {
		// SQL Query
		$sql = "SELECT api.remove_system({$this->db->escape($sys->get_system_name())})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
	public function remove_interface($int) {
		// SQL Query
		$sql = "SELECT api.remove_interface({$this->db->escape($int->get_mac())})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
	public function remove_interface_address($addr) {
		// SQL Query
		$sql = "SELECT api.remove_interface_address({$this->db->escape($addr->get_address())})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
	
	////////////////////////////////////////////////////////////////////////
	// UTILITY FUNCTIONS

	public function renew($sys) {
		// SQL Query
		$sql = "SELECT api.renew_system({$this->db->escape($sys->get_system_name())})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
}

/* End of file api_systems.php */
/* Location: ./application/models/API/api_systems.php */
