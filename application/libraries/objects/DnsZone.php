<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class DnsZone extends ImpulseObject {
	
	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	private $zone;
	private $keyname;
	private $forward;
	private $shared;
	private $owner;
	private $comment;
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

    public function __construct($zone, $keyname, $forward, $shared, $owner, $comment, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// Object specific data
		$this->zone    = $zone;
		$this->keyname = $keyname;
		$this->forward = $forward;
		$this->shared  = $shared;
		$this->owner   = $owner;
        $this->comment = $comment;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_zone()    { return $this->zone; }
	public function get_keyname() { return $this->keyname; }
	public function get_forward() { return $this->forward; }
	public function get_shared()  { return $this->shared; }
	public function get_owner()   { return $this->owner; }
	public function get_comment() { return $this->comment; }
	

    ////////////////////////////////////////////////////////////////////////
	// SETTERS

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
    
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file DnsZone.php */
/* Location: ./application/libraries/objects/DnsZone.php */