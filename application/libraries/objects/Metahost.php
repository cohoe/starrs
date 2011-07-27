<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Metahost extends ImpulseObject {
	
	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// string	The name of the metahost
	private $name;
	
	// string	A comment on the metahost
	private $comment;
	
	// string	The owning username
	private $owner;
	
	// array<InterfaceAddress>	The members of this metahost
	private $members = array();
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	public function __construct($name,$comment,$owner,$dateCreated,$dateModified,$lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// Metahost specific stuff
		$this->name = $name;
		$this->comment = $comment;
		$this->owner = $owner;
	}
	
	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_name()    { return $this->name; }
	public function get_comment() { return $this->comment; }
	public function get_owner()   { return $this->owner; }
	public function get_members() { return $this->members; }
	
	////////////////////////////////////////////////////////////////////////
	// SETTERS
	
	public function set_name($new) {
		$this->CI->api->firewall->modify_metahost($this->name, 'name', $new);
		$this->name = $new;
	}
	
	public function set_comment($new) {
		$this->CI->api->firewall->modify_metahost($this->name, 'comment', $new);
		$this->comment = $new;
	}
	
	public function set_owner($new) {
		$this->CI->api->firewall->modify_metahost($this->name, 'owner', $new);
		$this->owner = $new;
	}

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
	
	public function add_member($membr) {
		if(!($membr instanceof MetahostMember)) {
			throw new ObjectException("Cannot add non-member object as a metahost member");
		}
		$this->members[$membr->get_address()] = $membr;
	}
	
	public function get_member($address) {
		if(!isset($this->members[$address])) {
			throw new ObjectNotFoundException("Interface address is not a member of this metahost");
		}
		return $this->members[$address];
	}

	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file Metahost.php */
/* Location: ./application/libraries/objects/Metahost.php */