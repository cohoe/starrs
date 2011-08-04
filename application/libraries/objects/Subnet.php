<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Subnet extends ImpulseObject {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES

	private $name;
	private $subnet;
	private $zone;
	private $owner;
	private $autogen;
	private $dhcpEnable;
	private $comment;
	private $fwPrimaryAddress;
	private $fwSecondaryAddress;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

    public function __construct($name, $subnet, $zone, $owner, $autogen, $dhcpEnable, $comment, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// Object specific data
		$this->name       = $name;
		$this->subnet     = $subnet;
        $this->zone       = $zone;
        $this->owner      = $owner;
        $this->autogen    = $autogen;
        $this->dhcpEnable = $dhcpEnable;
        $this->comment    = $comment;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_name()               { return $this->name; }
	public function get_subnet()             { return $this->subnet; }
	public function get_zone()               { return $this->zone; }
	public function get_owner()              { return $this->owner; }
	public function get_autogen()            { return $this->autogen; }
    public function get_dhcp_enable()        { return $this->dhcpEnable; }
	public function get_comment()            { return $this->comment; }
	public function get_firewall_primary()   { return $this->fwPrimaryAddress; }
	public function get_firewall_secondary() { return $this->fwSecondaryAddress; }

    ////////////////////////////////////////////////////////////////////////
	// SETTERS
	
	public function set_firewall_primary($address)   { $this->fwPrimaryAddress = $address; }
	public function set_firewall_secondary($address) { $this->fwSecondaryAddress = $address; }
	
	public function set_name($new) {
		$this->CI->api->ip->modify->subnet($this->subnet, 'name', $new);
		$this->name = $new;
	}
	
	public function set_subnet($new) {
		$this->CI->api->ip->modify->subnet($this->subnet, 'subnet', $new);
		$this->name = $new;
	}
	
	public function set_zone($new) {
		$this->CI->api->ip->modify->subnet($this->subnet, 'zone', $new);
		$this->zone = $new;
	}
	
	public function set_owner($new) {
		$this->CI->api->ip->modify->subnet($this->subnet, 'owner', $new);
		$this->owner = $new;
	}
	
	public function set_autogen($new) {
		$this->CI->api->ip->modify->subnet($this->subnet, 'autogen', $new);
		$this->autogen = $new;
	}
	
	public function set_dhcp_enable($new) {
		$this->CI->api->ip->modify->subnet($this->subnet, 'dhcp_enable', $new);
		$this->dhcpEnable = $new;
	}
	
	public function set_comment($new) {
		$this->CI->api->ip->modify->subnet($this->subnet, 'comment', $new);
		$this->comment = $new;
	}

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
    
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file Subnet.php */
/* Location: ./application/libraries/objects/Subnet.php */