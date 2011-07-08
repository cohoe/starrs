<?php
/*
 * This class contains the definition for a the System object. A system is 
 * essentially a server/machine that is part of the network.
 */
class System extends ImpulseObject {
	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// string	A descriptive comment about the system
	private $comment;
	
	// bool		Whether or not the system is complete (contains interfaces)
	private $hasInterfaces = false;
	
	// array<InterfaceObjects>	The interfaces associated with the system
	private $interfaces;
	
	// string	The OS that the system is running
	private $osName;
	
	// string	The user who owns the system
	private $owner;
	
	// long		The date the system was renewed, stored as a Unix timestamp
	private $renewDate;
	
	// string	The name of the system
	private $systemName;
	
	// string	The type of system
	private $type;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	/**
	 * Construct a new DnsRecord from the given information
	 * @param	string	$systemName		The name of the system to create
	 * @param	string	$owner			The owning username of the system
	 * @param	string	$comment		A comment on the system
	 * @param	string	$type			The type of system
	 * @param	string	$osName			The name of the primary operating system
	 * @param	long	$renewDate		The date the system needs renewed on
	 * @param	long	$dateCreated	Unix timestamp when the record was created
	 * @param	long	$dateModified	Unix timestamp when the record was modifed
	 * @param	string	$lastModifer	The last user to modify the record 
	 */
	public function __construct($systemName, $owner, $comment, $type, $osName, $renewDate, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// Store the rest of the data
		$this->systemName 	= $systemName;
		$this->owner 		= $owner;
		$this->comment 		= $comment;
		$this->type			= $type;
		$this->osName		= $osName;
		$this->renewDate	= $renewDate; 
		
		// Initialize other vars
		$hasInterfaces = false;
		$interfaces = array();
		
		// Load interfaces
		$interface_info = $this->CI->api->get_system_interfaces($this->systemName);
		foreach ($interface_info as $interface) {
			$this->add_interface(new NetworkInterface(
				$interface->get_mac(),
				$interface->get_comment(),
				$interface->get_system_name(),
				$interface->get_interface_name(),
				$interface->get_date_created(),
				$interface->get_date_modified(),
				$interface->get_last_modifier()
			));
		}
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_system_name()   { return $this->systemName; }
	public function get_owner()         { return $this->owner; }
	public function get_comment()       { return $this->comment; }
	public function get_renew_date()    { return $this->renewDate; }
	public function get_type()          { return $this->type; }
	public function get_os_name()       { return $this->osName; }
	public function get_interfaces()    { return $this->interfaces; }
	
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
	
	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
	
	/**
	 * Adds an interface to the system
	 * @param InterfaceObject	$interface	The interface to add to the system
	 */
	public function add_interface($interface) {
		// If it's not an interface, blow up
		if($interface instanceof InterfaceObject) {
			throw new APIException("Cannot add a non-interface as an interface");
		}
		
		// Add an interface to the local interfaces array
		$this->interfaces[] = $interface;
		$this->hasInterfaces = true;
	}
}
