<?php
/**
 * @throws AmbiguousTargetException|DBException|ObjectNotFoundException
 *
 */
class API_Systems extends CI_Model {
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

    /**
     *
     */
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
		$sql = "SELECT api.create_system(
			{$this->db->escape($systemName)},
			{$this->db->escape($owner)},
			{$this->db->escape($type)},
			{$this->db->escape($osName)},
			{$this->db->escape($comment)})";
			
		$query = $this->db->query($sql);
		
		$return = "OK";
		// Error conditions
		try {
			if($this->db->_error_number() > 0) {
				throw new DBException($this->db->_error_message());
			}
			if($this->db->_error_message() != "") {
				throw new DBException($this->db->_error_message());
			}
		}
		catch (DBException $dbE) {
			$return = $dbE->getMessage();
		}
		return $return;
	}
	
	public function create_interface($systemName, $mac, $interfaceName, $comment) {
		$sql = "SELECT api.create_interface(
			{$this->db->escape($systemName)},
			{$this->db->escape($mac)},
			{$this->db->escape($interfaceName)},
			{$this->db->escape($comment)})";
			
		$query = $this->db->query($sql);
		
		$return = "OK";
		// Error conditions
		try {
			if($this->db->_error_number() > 0) {
				throw new DBException($this->db->_error_message());
			}
			if($this->db->_error_message() != "") {
				throw new DBException($this->db->_error_message());
			}
		}
		catch (DBException $dbE) {
			$return = $dbE->getMessage();
		}
		return $return;
	}
	
	public function create_interface_address($mac, $address, $config, $class, $isprimary, $comment) {
	
		$sql = "SELECT api.create_interface_address(
			{$this->db->escape($mac)},
			{$this->db->escape($address)},
			{$this->db->escape($config)},
			{$this->db->escape($class)},
			{$this->db->escape($isprimary)},
			{$this->db->escape($comment)}
		)";
		
		$query = $this->db->query($sql);
		
		$return = "OK";
		// Error conditions
		try {
			if($this->db->_error_number() > 0) {
				throw new DBException($this->db->_error_message());
			}
			if($this->db->_error_message() != "") {
				throw new DBException($this->db->_error_message());
			}
		}
		catch (DBException $dbE) {
			$return = $dbE->getMessage();
		}
		return $return;
	}
	
	
	////////////////////////////////////////////////////////////////////////
	// GET FUNCTIONS

    /**
     * @param null $owner
     * @return array
     */
	public function get_systems($owner=null) {
        // Generate the SQL
		// This function can take NULL as an arg
        $sql = "SELECT api.get_systems({$this->db->escape($owner)})";

        // Run the query
        $query = $this->db->query($sql);

        // Create the array of objects
        $systemSet = array();
        foreach($query->result_array() as $system) {
            $systemSet[] = $system['get_systems'];
        }

        // Return the array
        return $systemSet;
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

		// Run the query
		$sql = "SELECT * FROM api.get_system_data({$this->db->escape($systemName)})";
		$query = $this->db->query($sql);

				
		// Error conditions
		if($this->db->_error_number() > 0) {
			throw new DBException("A database error occurred: " . $this->db->_error_message());
		}
		if($query->num_rows() == 0) {
			throw new ObjectNotFoundException("The system could not be found: '{$systemName}'");
		}
		if($query->num_rows() > 1) {
			throw new AmbiguousTargetException("More than one system matches '{$systemName}'");
		}
		
		// It was valid! Create the system
		$system = $query->row_array();
		#$system = $system[0];
		$systemResult = new System(
			$system['system_name'], 
			$system['owner'], 
			$system['comment'], 
			$system['type'], 
			$system['os_name'],
			$system['renew_date'],
			$system['date_created'],
			$system['date_modified'],
			$system['last_modifier']);
		
		//Are we making a complete system
		if($complete == true) {
			// Grab the interfaces that the system has
			foreach($this->get_system_interfaces($systemName, $complete) as $interface) {
				$systemResult->add_interface($interface);
			} 
		}
		
		// Return the system object
		return $systemResult;
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

		$sql = "SELECT * FROM api.get_system_interfaces({$this->db->escape($systemName)})";
		$query = $this->db->query($sql);

		// Error conditions
		if($this->db->_error_number() > 0) {
			throw new DBException("A database error occurred: " . $this->db->_error_message());
		}
		if($query->num_rows() == 0) {
			#throw new ObjectNotFoundException("No interfaces matching the system name '{$systemName}' could not be found.");
		}
		
		// There were interfaces that matched, build them and return them
		$interfaceSet = array();
		foreach($query->result_array() as $row) {
			// Create the interface
			$interface = new NetworkInterface(
				$row['mac'], 
				$row['comment'], 
				$row['system_name'], 
				$row['name'],
				$row['date_created'], 
				$row['date_modified'], 
				$row['last_modifier']
			);
			
			if($complete == true) {
				$iA = $this->get_interface_addresses($row['mac'],$complete);
				foreach($iA as $address) {
					$interface->add_address($address);
				}
			}
			
			// Add the machine to the result set
			$interfaceSet[] = $interface;
		}
		
		return $interfaceSet;
	}
	
	public function get_system_interface_data($mac, $complete=false) {
		
		$sql = "SELECT * FROM api.get_system_interface_data({$this->db->escape($mac)})";
		$query = $this->db->query($sql);
		// Error conditions
		if($this->db->_error_number() > 0) {
			throw new DBException("A database error occurred: " . $this->db->_error_message());
		}
		if($this->db->_error_message() != "") {
			throw new DBException($this->db->_error_message());
		}
		
		$result = $query->row_array();
		$interface = new NetworkInterface(
			$result['mac'],
			$result['comment'],
			$result['system_name'],
			$result['name'],
			$result['date_created'],
			$result['date_modified'],
			$result['last_modifier']
		);
		
		if($complete == true) {
			$iA = $this->get_system_interface_addresses($result['mac'],$complete);
			foreach($iA as $address) {
				$interface->add_address($address);
			}
		}
		
		return $interface;
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
				
		// Run the query
		// This is DESC for temporary viewing purposes. It will be made ASC later
		$sql = "SELECT * FROM api.get_system_interface_addresses({$this->db->escape($mac)})";
		$query = $this->db->query($sql);
		
		// Check for errors
		if($this->db->_error_number() > 0) {
			throw new DBException("A database error occurred: " . $this->db->_error_message());
		}
		
		// Create the objects
		$addressSet = array();
		foreach($query->result_array() as $row) {
			$address = new InterfaceAddress(
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
                $fwRules = $this->api->firewall->get_address_rules($row['address']);
                foreach($fwRules as $fwRule) {
                    $address->add_firewall_rule($fwRule);
                }

                // Load DNS pointer records
                $pointerRecords = $this->api->dns->get_pointer_records($row['address']);
                foreach ($pointerRecords as $pointerRecord) {
                    $address->add_pointer_record($pointerRecord);
                }

                // Load DNS text records
                $txtRecords = $this->api->dns->get_txt_records($row['address']);
                foreach ($txtRecords as $txtRecord) {
                    $address->add_txt_record($txtRecord);
                }

                // Load DNS nameserver records
                $nsRecords = $this->api->dns->get_ns_records($row['address']);
                foreach ($nsRecords as $nsRecord) {
                    $address->add_ns_record($nsRecord);
                }

                // Load DNS mailserver records
                $mxRecords = $this->api->dns->get_mx_records($row['address']);
                foreach ($mxRecords as $mxRecord) {
                    $address->add_mx_record($mxRecord);
                }
            }

            // Add the address to the array
            $addressSet[] = $address;
		}

        // Return the array of addresses
		return $addressSet;
	}
	
	public function get_system_inteface_address($address, $complete=false) {
				
		// Run the query
		$sql = "SELECT * FROM systems.interface_addresses WHERE address={$this->db->escape($address)}";
		$query = $this->db->query($sql);
		
		// Check for errors
		if($this->db->_error_number() > 0) {
			throw new DBException("A database error occurred: " . $this->db->_error_message());
		}
		
		$row = $query->row_array();
		
		// Create the objects
		$address = new InterfaceAddress(
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
			$fwRules = $this->api->firewall->get_address_rules($row['address']);
			foreach($fwRules as $fwRule) {
				$address->add_firewall_rule($fwRule);
			}

			// Load DNS pointer records
			$pointerRecords = $this->api->dns->get_pointer_records($row['address']);
			foreach ($pointerRecords as $pointerRecord) {
				$address->add_pointer_record($pointerRecord);
			}

			// Load DNS text records
			$txtRecords = $this->api->dns->get_txt_records($row['address']);
			foreach ($txtRecords as $txtRecord) {
				$address->add_txt_record($txtRecord);
			}

			// Load DNS nameserver records
			$nsRecords = $this->api->dns->get_ns_records($row['address']);
			foreach ($nsRecords as $nsRecord) {
				$address->add_ns_record($nsRecord);
			}

			// Load DNS mailserver records
			$mxRecords = $this->api->dns->get_mx_records($row['address']);
			foreach ($mxRecords as $mxRecord) {
				$address->add_mx_record($mxRecord);
			}
		}

        // Return the array of addresses
		return $address;
	}

    /**
     * @return array
     */
	public function get_system_types() {
		$sql = "SELECT api.get_system_types()";
		$query = $this->db->query($sql);
		
		$types = array();
		foreach($query->result_array() as $result) {
			$types[] = $result['get_system_types'];
		}

		return $types;
	}

    /**
     * @return array
     */
	public function get_operating_systems() {
		$sql = "SELECT api.get_operating_systems()";
		$query = $this->db->query($sql);
		
		$oss = array();
		foreach($query->result_array() as $os) {
			$oss[] = $os['get_operating_systems'];
		}

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
		$sql = "SELECT api.get_interface_owner('{$int->get_mac()}')";
		$query = $this->db->query($sql);
		return $query->row()->get_interface_owner;
	}
	
	public function get_interface_address_system($address) {
		$sql = "SELECT api.get_interface_address_system({$this->db->escape($address)})";
		$query = $this->db->query($sql);
		return $query->row()->get_interface_address_system;
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
		$sql = "SELECT api.modify_system({$this->db->escape($systemName)}, {$this->db->escape($field)}, {$this->db->escape($newValue)})";
		$query = $this->db->query($sql);
		$return = "OK";
		// Error conditions
		try {
			if($this->db->_error_message() != "") {
				throw new DBException($this->db->_error_message());
			}
		}
		catch (DBException $dbE) {
			$return = $dbE->getMessage();
		}
		return $return;
	}
	
	public function modify_interface($mac, $field, $newValue) {
		$sql = "SELECT api.modify_interface({$this->db->escape($mac)}, {$this->db->escape($field)}, {$this->db->escape($newValue)})";
		$query = $this->db->query($sql);
		$return = "OK";
		// Error conditions
		try {
			if($this->db->_error_message() != "") {
				throw new DBException($this->db->_error_message());
			}
		}
		catch (DBException $dbE) {
			$return = $dbE->getMessage();
		}
		return $return;
	}
	
	
	
	////////////////////////////////////////////////////////////////////////
	// REMOVE FUNCTIONS

    /**
     * @throws DBException
     * @param $sys
     * @return string
     */
	public function remove_system($sys) {
		$sql = "SELECT api.remove_system({$this->db->escape($sys->get_system_name())})";
		$query = $this->db->query($sql);
		$return = "OK";
		// Error conditions
		try {
			if($this->db->_error_message() != "") {
				throw new DBException($this->db->_error_message());
			}
		}
		catch (DBException $dbE) {
			$return = $dbE->getMessage();
		}
		return $return;
	}
	
	public function remove_interface($int) {
		$sql = "SELECT api.remove_interface({$this->db->escape($int->get_mac())})";
		$query = $this->db->query($sql);
		$return = "OK";
		// Error conditions
		try {
			if($this->db->_error_message() != "") {
				throw new DBException($this->db->_error_message());
			}
		}
		catch (DBException $dbE) {
			$return = $dbE->getMessage();
		}
		return $return;
	}
	
	public function remove_interface_address($addr) {
		$sql = "SELECT api.remove_interface_address({$this->db->escape($addr->get_address())})";
		$query = $this->db->query($sql);
		$return = "OK";
		// Error conditions
		try {
			if($this->db->_error_message() != "") {
				throw new DBException($this->db->_error_message());
			}
		}
		catch (DBException $dbE) {
			$return = $dbE->getMessage();
		}
		return $return;
	}
	
	
	
	////////////////////////////////////////////////////////////////////////
	// UTILITY FUNCTIONS

	public function renew($sys) {
		$sql = "SELECT api.renew_system({$this->db->escape($sys->get_system_name())})";
		$query = $this->db->query($sql);
		$return = "OK";
		// Error conditions
		try {
			if($this->db->_error_message() != "") {
				throw new DBException($this->db->_error_message());
			}
		}
		catch (DBException $dbE) {
			$return = $dbE->getMessage();
		}
		return $return;
	}
	
}
