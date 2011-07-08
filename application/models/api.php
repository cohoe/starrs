<?php

class Api extends CI_Model {

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	/* Constructor
	This class does database work. That is all. These functions are the
	only access to the database you get.
	*/
	function __construct()
	{
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
	public function intialize($user)
	{
		// Escape it!
		$user = $this->db->escape($user);
		
		// Run it!
		$sql = "SELECT api.initialize({$user})";
		$query = $this->db->query($sql);
		
		return $query;
	}
	
	/**
	 * Deinitializes the API for usage with the already provided user.
	 * @return	bool			True on success
	 * 							False on recoverable failure
	 */
	public function deinitialize()
	{
		// Run the query
		$sql = "SELECT api.deinitialize()";
		$query = $this->db->query($sql);
		
		if($this->db->_error_number() > 0) {
			throw new DBException("A database error occurred: " . $this->db->_error_message());
		}
		
		return true;
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
	public function get_system_info($systemName, $complete=false)
	{
		// Escape the code
		$systemName = $this->db->escape($systemName);
		
		// Run the query
		$sql = "SELECT * FROM systems.systems WHERE system_name={$systemName}";
		$query = $this->db->query($sql);
				
		// Error conditions
		if($this->db->_error_number() > 0) {
			throw new DBException("A database error occurred: " . $this->db->_error_message());
		}
		if($query->num_rows() == 0) {
			throw new ObjectNotFoundException("The system could not be found: '{$systemName}'");
		}
		if($query->num_rows() > 1) {
			throw new AmbiguousTarget("More than one system matches '{$systemName}'");
		}
		
		// It was valid! Create the system
		$system = $query->row_array();
		$system = $system[0];
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
		if($complete) {
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
	public function get_system_interfaces($systemName, $complete=false)
	{
		// Escape the system name, run the query
		$systemName = $this->db->escape($systemName);
		$sql = "SELECT * FROM systems.interfaces WHERE system_name = {$systemName} ORDER BY mac ASC";
		$query = $this->db->query($sql);
		
		// Error conditions
		if($this->db->_error_number() > 0) {
			throw new DBException("A database error occurred: " . $this->db->_error_message());
		}
		if($query->num_rows == 0) {
			throw new ObjectNotFoundException("No interfaces matching the system name '{$systemName}' could not be found.");
		}
		
		// There were interfaces that matched, build them and return them
		$resultSet = array();
		foreach($query->row_array() as $row) {
			// Create the interface
			$interface = new InterfaceObject(
				$row['mac'], 
				$row['comment'], 
				$row['system'], 
				$row['date_created'], 
				$row['date_modified'], 
				$row['last_modifier']
			);
			
			// @todo: Handle other objects here
			if($complete) {
				$iA = get_interface_addresses($mac);
				foreach($iA as $address) {
					$interface->add_address($address);
				}
			}
			
			// Add the machine to the result set
			$resultSet[] = $interface;
		}
		
		return $resultSet;
	}
	
	/**
	 * Query the database for the interface addresses associated with the given
	 * MAC address.
	 * @param	string			The mac address to look up
	 * @throws	DBException				Thrown if the database shit the bed
	 * @throws	ObjectNotFoundException	Thrown if the mac address is not in the db
	 * @return	array<Address>	An arry of addresses associated with the interface
	 */
	public function get_interface_addresses($mac)
	{
		// Escape the address
		$mac = $this->db->escape($mac);
				
		// Run the query
		// This is DESC for temporary viewing purposes. It will be made ASC later
		$sql = "SELECT * from systems.interface_addresses WHERE mac = '{$mac}' ORDER BY name DESC";
		$query = $this->db->query($sql);
		
		// Check for errors
		if($this->db->_error_number() > 0) {
			throw new DBException("A database error occurred: " . $this->db->_error_message());
		}
		if($query->num_rows == 0) {
			throw new ObjectNotFoundException("No addresses matching the  name '{$systemName}' could not be found.");
		}
		
		// Create the objects
		$resultSet = array();
		foreach($query->row_array() as $row) {
			$resultSet[] = new InterfaceAddress(
				$row['address'], 
				$row['class'], 
				$row['config'], 
				$row['mac'], 
				$row['renew_date'], 
				$row['comment'], 
				$row['date_created'], 
				$row['date_modified'], 
				$row['last_modifer']
			);
		}
		
		return $resultSet;
	}
	
	public function get_address_rules($address)
	{
		$sql = "SELECT * from firewall.rules JOIN firewall.programs ON firewall.rules.port = firewall.programs.port WHERE address = '$address' ORDER BY source,firewall.rules.port ASC";
		$query = $this->db->query($sql);
		return $query->result_array();
	}

	public function get_schema_documentation($schema)
	{
		if ($schema != "none")
		{
			$sql = "SELECT * FROM documentation.functions WHERE schema = '$schema' ORDER BY schema,name ASC";
		}
		else
		{
			$sql = "SELECT * FROM documentation.functions ORDER BY schema,name ASC";
		}
		$query = $this->db->query($sql);
		print_r($query);
		return $query->result_array();
	}

	public function get_function_parameters($function)
	{
		$sql = "select * from documentation.arguments where specific_name = '$function' order by position asc";
		$query = $this->db->query($sql);
		return $query->result_array();
	}
	
	public function get_ip_fqdn($address)
	{
		$sql = "SELECT hostname||'.'||zone AS fqdn FROM dns.a WHERE address = '$address'";
		$query = $this->db->query($sql);
		#$arr = $query->result_array();
		#print_r($arr);
		#echo $arr;
		return $query->row()->fqdn;
	}
	
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
