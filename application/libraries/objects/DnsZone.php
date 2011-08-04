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
	
	public function set_zone($new) {
		$this->CI->api->dns->modify->zone($this->zone, 'zone', $new);
		$this->zone = $new;
	}
	
	public function set_keyname($new) {
		$this->CI->api->dns->modify->zone($this->zone, 'keyname', $new);
		$this->keyname = $new;
	}
	
	public function set_forward($new) {
		$this->CI->api->dns->modify->zone($this->zone, 'forward', $new);
		$this->forward = $new;
	}
	
	public function set_shared($new) {
		$this->CI->api->dns->modify->zone($this->zone, 'shared', $new);
		$this->shared = $new;
	}
	
	public function set_owner($new) {
		$this->CI->api->dns->modify->zone($this->zone, 'owner', $new);
		$this->owner = $new;
	}
	
	public function set_comment($new) {
		$this->CI->api->dns->modify->zone($this->zone, 'comment', $new);
		$this->comment = $new;
	}
	

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
    
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file DnsZone.php */
/* Location: ./application/libraries/objects/DnsZone.php */