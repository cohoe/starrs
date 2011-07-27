<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class MetahostMember extends ImpulseObject {
	
	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// string	The name of the metahost
	private $name;
	
	// string	The interface address that belongs to the metahost
	private $address;
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	public function __construct($name,$address,$dateCreated,$dateModified,$lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// Metahost specific stuff
		$this->name = $name;
		$this->address = $address;
	}
	
	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_name()    { return $this->name; }
	public function get_address() { return $this->address; }
	
	////////////////////////////////////////////////////////////////////////
	// SETTERS

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS

	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file MetahostMember.php */
/* Location: ./application/libraries/objects/MetahostMember.php */