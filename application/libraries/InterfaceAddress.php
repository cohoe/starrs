<?php

/*
 * This class contains the definition of an InterfaceAddress object. These
 * objects represent an address tied to the
 * specified address.
 */
class InterfaceAddress extends IMPULSEObject {
	////////////////////////////////////////////////////////////////////////
	// ENUM-LIKE SILLYNESS
	
	// Enumeration values for address family
	public static $IPv4 = 4;
	public static $IPv6 = 6;
	
	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// string		The address bound to the interface 
	private $address;
	
	// string		The class of the address (all values are default so far)
	private $class;
	
	// string		A comment about the address
	private $comment;
	
	// string		The config type for the address
	// @todo: make a getValidConfigTypes method
	private $config;
	
	// enum(int)	The family the address belongs to (either IPv4 or v6). Can
	// be compared against using ::$IPv4 and ::$IPv6
	private $family;
	
	// string		The mac address that this address is bound to. Can be used
	// to lookup the matching InterfaceObject. 
	private $mac;
	
	// long			The unix timestamp that the interface will be renewed.
	private $renewDate;
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	/**
	 * Construct a new InterfaceAddress object using the given information
	 * @param 	string 	$address		The address bound to the address 
	 * @param 	string 	$class			The class of the address
	 * @param 	string	$config			How the address is configured
	 * @param 	string 	$mac			The mac address the interface address 
	 * 									is bound to
	 * @param 	long	$renewDate		Unix timestamp when the address renews
	 * @param 	string	$comment		A comment about the address
	 * @param	long	$dateCreated	Unix timestamp when the address was created
	 * @param	long	$dateModified	Unix timestamp when the address was modifed
	 * @param	string	$lastModifer	The last user to modify the address 
	 */
	public function __construct($address, $class, $config, $mac, $renewDate, $comment, $dateCreated, $dateModified, $lastModifer) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// InterfaceAddress-specific stuff
		$this->address   = $address;
		$this->class     = $class;
		$this->config    = $config;
		$this->mac       = $mac;
		$this->renewDate = $renewDate;
		$this->comment   = $comment; 
		
		// Determine the family of the address based on whether there's a : or not
		$this->family  = (strpos($address, ':') === false) ? self::$IPv4 : self::$IPv6;
	}
	
	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_address()    { return $this->address; }
	public function get_class()      { return $this->class; }
	public function get_config()     { return $this->config; }
	public function get_mac()        { return $this->mac; }
	public function get_renew_date() { return $this->renewDate; }
	public function get_comment()    { return $this->comment; }
	public function get_family()     { return $this->family; }
}