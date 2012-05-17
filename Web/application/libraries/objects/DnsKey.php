<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class DnsKey extends ImpulseObject {
	
	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	private $keyname; 	
	private $key;
	private $owner;
	private $comment;
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

    public function __construct($keyname, $key, $owner, $comment, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// Object specific data
		$this->keyname = $keyname;
		$this->key     = $key;
		$this->owner   = $owner;
        $this->comment = $comment;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_keyname() { return $this->keyname; }
	public function get_key()     { return $this->key; }
	public function get_owner()   { return $this->owner; }
	public function get_comment() { return $this->comment; }
	

    ////////////////////////////////////////////////////////////////////////
	// SETTERS
	
	public function set_keyname($new) {
		$this->CI->api->dns->modify->key($this->keyname, 'keyname', $new);
		$this->keyname = $new;
	}
	
	public function set_key($new) {
		$this->CI->api->dns->modify->key($this->keyname, 'key', $new);
		$this->key = $new;
	}
	
	public function set_owner($new) {
		$this->CI->api->dns->modify->key($this->keyname, 'owner', $new);
		$this->owner = $new;
	}
	
	public function set_comment($new) {
		$this->CI->api->dns->modify->key($this->keyname, 'comment', $new);
		$this->comment = $new;
	}

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
    
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file DnsKey.php */
/* Location: ./application/libraries/objects/DnsKey.php */