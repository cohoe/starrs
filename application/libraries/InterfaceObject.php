<?php

/*
 * This class contains the definition for a the Interface object. An Interface
 * is essentially a connection to the network that a system posesses. It would
 * totally be called 'Interface' if that wasn't a keyword in PHP...
 */
class InterfaceObject extends IMPULSEObject {
	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// The MAC address of the interface
	private $mac;
	
	// Descriptive comment about the interface
	private $comment;
	
	// The system that this interface is associated
	private $systemName;
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	/**
	 * Constructs a new interface with the information proivided
	 * 
	 * @param	string	$mac		The mac address for the interface	
	 * @param	string	$comment	A descriptive comment about the interface
	 * @param	string	$system		The name of the system associated with the
	 * 								interface being constructed
	 * @param	long	$dateCreated The date the interface was created, Unix TS
	 * @param	long	$dateModified The date the interface was created, Unix TX
	 * @param	string	$lastModifier The last user to modify the system
	 */
	public function __construct($mac, $comment, $system, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// Store interface specific data
		$this->mac		= $mac;
		$this->comment	= $comment;
		$this->system	= $system;
	}
	
	
	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_mac() 		{ return $this->mac; }
	public function get_comment()	{ return $this->comment; }
	public function get_systemName(){ return $this->systemName; }
}