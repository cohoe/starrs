<?php

/**
 * The IMPULSE API - the only supported way to interact with the IMPULSE database. 
 */
class Api extends CI_Model {

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	/* Constructor
	This class does database work. That is all. These functions are the
	only access to the database you get.
	*/
	function __construct() {
		parent::__construct();
	}
	
	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
	
	/**
	 * Initiaizes the API for usage with the given user.
	 * @param 	string 	$user	The username to initialze the db with
	 * @return	bool			True on success
	 * 							False on recoverable error
	 */
	public function initialize($user) {
		
		// Run it!
		$sql = "SELECT api.initialize({$this->db->escape($user)})";
		$query = $this->db->query($sql);
		
		return $query;
	}
	
	/**
	 * Deinitializes the API for usage with the already provided user.
	 * @return	bool			True on success
	 * 							False on recoverable failure
	 */
	public function deinitialize() {
		// Run the query
		$sql = "SELECT api.deinitialize()";
		$query = $this->db->query($sql);
		
		if($this->db->_error_number() > 0) {
			throw new DBException("A database error occurred: " . $this->db->_error_message());
		}
		
		return true;
	}

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
	public function get_system_info($systemName, $complete=false) {

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
			throw new ObjectNotFoundException("No interfaces matching the system name '{$systemName}' could not be found.");
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

    /**
     * Query the database for the interface addresses associated with the given
	 * MAC address
     * @param $mac                      The MAC address of the interface to search on
     * @param bool $complete            Are we making a complete system
     * @throws	DBException				Thrown if the database shit the bed
     * @return array<InterfaceAddress>  An array of InterfaceAddress objects
     */
    public function get_interface_addresses($mac, $complete=false) {
				
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
                $fwRules = $this->get_address_rules($row['address']);
                foreach($fwRules as $fwRule) {
                    $address->add_firewall_rule($fwRule);
                }

                // Load DNS pointer records
                $pointerRecords = $this->get_pointer_records($row['address']);
                foreach ($pointerRecords as $pointerRecord) {
                    $address->add_pointer_record($pointerRecord);
                }

                // Load DNS text records
                $txtRecords = $this->get_txt_records($row['address']);
                foreach ($txtRecords as $txtRecord) {
                    $address->add_txt_record($txtRecord);
                }

                // Load DNS nameserver records
                $nsRecords = $this->get_ns_records($row['address']);
                foreach ($nsRecords as $nsRecord) {
                    $address->add_ns_record($nsRecord);
                }

                // Load DNS mailserver records
                $mxRecords = $this->get_mx_records($row['address']);
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

    /**
     * @param $address
     * @return array
     */
    public function get_address_rules($address) {
		$sql = "SELECT * FROM api.get_firewall_rules({$this->db->escape($address)})";
		$query = $this->db->query($sql);

        $ruleSet = array();

        foreach($query->result_array() as $fwRule) {
            $ruleSet[] = new FirewallRule(
                $fwRule['port'],
                $fwRule['transport'],
                $fwRule['deny'],
                $fwRule['comment'],
                $fwRule['address'],
                $fwRule['owner'],
                $fwRule['source'],
                $fwRule['date_created'],
                $fwRule['date_modified'],
                $fwRule['last_modifier']
            );
        }

        // Return the array of rules
        return $ruleSet;
	}

    /**
     * @param $schema
     * @return array
     */
    public function get_schema_documentation($schema) {
		if ($schema != "none") {
			$sql = "SELECT * FROM documentation.functions WHERE schema = '$schema' ORDER BY schema,name ASC";
		}
		else {
			$sql = "SELECT * FROM documentation.functions ORDER BY schema,name ASC";
		}
		$query = $this->db->query($sql);
		return $query->result_array();
	}

    /**
     * @param $function
     * @return array
     */
    public function get_function_parameters($function) {
		$sql = "select * from documentation.arguments where specific_name = '$function' order by position asc";
		$query = $this->db->query($sql);
		return $query->result_array();
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

    /**
     * Get the name of a firewall program based on its port
     * @param $port     The port of the program to search on
     * @return string   The name of the program
     */
    public function get_firewall_program($port) {
		$sql = "SELECT api.get_firewall_program_name({$this->db->escape($port)})";
		$query = $this->db->query($sql);
		return $query->row()->get_firewall_program_name;
	}

    /**
     * Get the default firewall action of an address
     * @param $address  The address to search on
     * @return bool     Deny (t) the traffic or allow (f)
     */
    public function get_firewall_default($address) {
		$sql = "SELECT api.get_firewall_default({$this->db->escape($address)})";
		$query = $this->db->query($sql);
		if($query->num_rows() == 1) {
			return $query->row()->get_firewall_default;
		} else {
			throw new ObjectNotFoundException("Could not find a defailt firewall action for the specified address {$address}");
		}
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
     * @throws	AmbiguousTargetException	Thrown if there is more than 1 record
     * 										gathered from the database
     * @throws	ObjectNotFoundException		Thrown if no records were returned
     * @return	MxRecord		The MX Record for the provided address 
     */
    public function get_mx_records($address) {
		$sql = "SELECT * FROM api.get_dns_mx({$this->db->escape($address)})";
		$query = $this->db->query($sql);

		// If there were more than one result; that's not good.
		if($query->num_rows() > 1) {
			throw new AmbiguousTargetException("More than one MX record was found for the given address ({$address}).");
		}
		if($query->num_rows() < 1) {
			throw new ObjectNotFoundException("An MX record for the given address ({$address}) could not be found."); 
		}
		
		// Grab the result, instantiate it as an object, then return it
		$result = $query->result_array();
		$result = $result[0];
		$result = new MxRecord(
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
		
        return $result;
	}
	
	////////////////////////////////////////////////////////////////////////
	// CREATION METHODS
	
	/**
	 * Execute the api command to create a new interface, given an interface obj
	 * @param 	NetworkInterface	$interface	A partial network interface to
	 * 											add to the database
	 * @throws 	APIException		Thrown when the provided interface is not a
	 * 								NetworkInterface instance
	 * @throws 	DBException			Thrown if the database query failed
	 */
	public function create_interface($interface) {
		// Verify that we have an interface
		if(!($interface instanceof NetworkInterface)) {
			throw new APIException("Cannot call create_instance with a non-NetworkInterface object (given ".get_class($interface).")");
		}
		
		// Build a query to create the interface
		$sql = "SELECT api.create_interface(";
		$sql .= $this->db->escape($interface->get_system_name()) . ',';
		$sql .= $this->db->escape($ingerface->get_mac()) . ',';
		$sql .= (($interface->get_comment()) ? $this->db->escape($interface->get_comment()) : "NULL") . ')'; 
		$result = $this->db->query($sql);
		
		// Error check
		if($this->db->_error_number() > 0) {
			throw new DBException("A database error occurred: " . $this->db->_error_message());
		}
	}
	
	/**
	 * Execute the api command to create a new interface address and associate
	 * it with a given interface.
	 * @param 	InterfaceAddress	$interfaceAddr	An interface address to associate
	 * 												with the given interface 	
	 * @param	NetworkInterface	$interface		A network interface for the address
	 * 												to be associated with
	 * @throws 	APIException		Thrown when the arguments are the incorrect type
	 * @throws 	DBException			Thrown if the database query failed
	 */
	public function create_interface_address($interfaceAddr, $interface) {
		// Verify that we have an interface and an InterfaceAddress
		if(!($interface instanceof NetworkInterface)) {
			throw new APIException("Cannot call create_instance_address with a non-NetworkInterface object (given ".get_class($interface).")");
		}
		if(!($interfaceAddr instanceof InterfaceAddress)) {
			throw new APIException("Cannot call create_instance_address with a non-InterfaceAddress object (given ".get_class($interfaceAddr).")");
		}
		
		// Build a query to create the interface address
		$sql = "SELECT api.create_interface_address(";
		$sql .= $this->db->escape($interface->get_mac()) . ',';
		$sql .= $this->db->escape($interfaceAddr->get_name()) . ',';
		$sql .= $this->db->escape($interfaceAddr->get_address()) . ',';
		$sql .= $this->db->escape($interfaceAddr->get_config()) . ',';
		$sql .= (($interfaceAddr->get_class()) ? $this->db->escape($interfaceAddr->get_class()) : "NULL") . ',';
		$sql .= (($interfaceAddr->get_isprimary()) ? "TRUE": "FALSE") . ',';
		$sql .= (($interfaceAddr->get_comment()) ? $this->db->escape($interfaceAddr->get_comment()) : "NULL") . ')';
		$result = $this->db->query($sql);
		
		// Error check
		if($this->db->_error_number() > 0) {
			throw new DBException("A database error occurred: " . $this->db->_error_message());
		}
	}
	
	/**
	 * Call the api command that creates a new system
	 * @param 	System	$system		A System filled with information for creating it
	 * @throws 	APIException		Thrown when the parameter is not a System
	 * @throws 	DBException			Thrown when the database shits the bed
	 */
	public function create_system($system) {
		// Verify that we have an instance of System
		if(!($system instanceof System)) {
			throw new APIException("Cannot call create_system with a non-System object (given ".get_class($system).")");
		}
		
		// Build a query to create the system
		$sql = "SELECT api.create_system(";
		$sql .= $this->db->escape($system->get_system_name()) . ',';
		// @todo: determine this value using webauth
		$sql .= (($system->get_owner()) ? $this->db->escape($system->get_owner()) : "NULL") . ',';
		$sql .= $this->db->escape($system->get_type()) . ',';
		$sql .= $this->db->escape($system->get_os_name()) . ',';
		$sql .= (($system->get_comment()) ? $this->db->escape($system->get_comment()) : "NULL") .')';
		$result = $this->db->query($sql);
		
		// Error check
		if($this->db->_error_number() > 0) {
			throw new DBException("A database error occurred: " . $this->db->_error_message());
		}
	}
	
	
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
