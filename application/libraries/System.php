<?php

// REQUIRED CLASSES
require_once 'IMPULSEObject.php';

/*
 * This class contains the definition for a the System object. A system is 
 * essentially a server/machine that is part of CSHNet.
 */
class System extends IMPULSEObject{
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
	
	public function __construct($sN, $own, $comm, $type, $os, $renew, $dateCreate, $dateMod, $lastMod) {
		// Chain into the parent
		parent::__construct($dateCreate, $dateMod, $lastMod);
		
		// Store the rest of the data
		$this->systemName 	= $sN;
		$this->owner 		= $own;
		$this->comment 		= $comm;
		$this->type			= $type;
		$this->osName		= $os;
		$this->renewDate	= $renew; 
		
		// Initialize other vars
		$hasInterfaces = false;
		$interfaces = array();
	}
	
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
		
		// Add an interface to the 
		$this->type[] = $interface;
	}
	
	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_system_name() 	{ return $this->systemName; }
	public function get_owner()			{ return $this->owner; }
	public function get_comment() 		{ return $this->comment; }
	public function get_type()			{ return $this->type; }
	public function get_os_name()		{ return $this->osName; }
	public function get_renew_date()	{ return $this->renewDate; }
}