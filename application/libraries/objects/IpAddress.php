<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class IpAddress extends ImpulseObject {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	private $address;
	private $owner;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

    public function __construct($address, $owner, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// Object specific data
		$this->address = $address;
		$this->owner   = $owner;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_address() { return $this->address; }
	public function get_owner()   { return $this->owner; }

    ////////////////////////////////////////////////////////////////////////
	// SETTERS
	
	/* None since IP addresses are controlled via subnets */

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
    
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file IpAddress.php */
/* Location: ./application/libraries/objects/IpAddress.php */