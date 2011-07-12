<?php
/*
* This class contains the definition for a the Interface object. An Interface
* is essentially a connection to the network that a system posesses. It would
* totally be called 'Interface' if that wasn't a keyword in PHP...
*/
class NetworkInterface extends ImpulseObject {
	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// string		MAC address of the physical interface
	private $mac;
	
	// string		A comment on the interface
	private $comment;
	
	// string		The name of the system that this interface is on
	private $systemName;
	
	// string		The interface logical name
	private $interfaceName;
	
	// array<InterfaceAddress>	All of the addresses on this interface
	private $addresses;
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

	/**
	 * Constructs a new interface with the information proivided
	 * 
	 * @param	string	$mac			The mac address for the interface	
	 * @param	string	$comment		A descriptive comment about the interface
	 * @param	string	$systemName		The name of the system associated with the
	 * 									interface being constructed
	 * @param	string	$interfaceName	The name of the interface
	 * @param	long	$dateCreated 	The date the interface was created, Unix TS
	 * @param	long	$dateModified 	The date the interface was created, Unix TX
	 * @param	string	$lastModifier 	The last user to modify the system
	 */
	public function __construct($mac, $comment, $systemName, $interfaceName, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);

		// Store interface specific data
		$this->mac = $mac;
		$this->comment = $comment;
		$this->system = $systemName;
		$this->interfaceName = $interfaceName;
		
		// Initialize variables
		$this->addresses = array();
		$address_info = $this->CI->api->get_interface_addresses($this->mac);
	}
	
	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_interface_name()        { return $this->interfaceName; }
	public function get_mac()                   { return $this->mac; }
	public function get_comment()               { return $this->comment; }
	public function get_system_name()           { return $this->systemName; }
	public function get_interface_addresses()   { return $this->addresses; }
	
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
	
	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
	
	/**
	 * Binds an interface address to the interface
	 * @param	InterfaceAddress	$interfaceAddress	The address to bind
	 * @throws	APIException		Thrown if the address is not an InterfaceAddress
	 */
	public function add_address($interfaceAddress) {
		if(!($interfaceAddress instanceof InterfaceAddress)) {
			throw new APIException("The given interface address (" . get_class($interfaceAddress) . ") is not an InterfaceAddress!");
		}
		$this->addresses[] = $interfaceAddress;
	}
}
