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
	
	private $rules = array();
	
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
	public function get_rules()   { return $this->rules; }
	
	////////////////////////////////////////////////////////////////////////
	// SETTERS
	
	public function set_name($new) {
		$this->CI->api->firewall->modify->metahost($this->name, 'name', $new);
		$this->name = $new;
	}
	
	public function set_comment($new) {
		$this->CI->api->firewall->modify->metahost($this->name, 'comment', $new);
		$this->comment = $new;
	}
	
	public function set_owner($new) {
		$this->CI->api->firewall->modify->metahost($this->name, 'owner', $new);
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
	
	public function add_rule($fwRule) {
		if(!($fwRule instanceof FirewallRule)) {
			throw new ObjectException("Cannot add non-rule object as a metahost firewall rule");
		}
		$this->rules[] = $fwRule;
	}
	
	public function get_rule($port, $transport) {
		foreach($this->rules as $rule) {
			if($rule->get_port() == $port && $rule->get_transport() == $transport) {
				return $rule;
			}
		}
		throw new ObjectNotFoundException("No firewall rule matching your criteria was found");
	}

	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file Metahost.php */
/* Location: ./application/libraries/objects/Metahost.php */