<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * Standalone firewall rule
 */
class StandaloneRule extends FirewallRule {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// string	The IP address to apply the rule to
	private $address;
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	public function __construct($address, $port, $transport, $deny, $comment, $owner, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($port, $transport, $deny, $comment, $owner, 'standalone-standalone', $dateCreated, $dateModified, $lastModifier);
		
		// StandaloneRule specific stuff
		$this->address = $address;
	}
	
	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_address() { return $this->address; }

    ////////////////////////////////////////////////////////////////////////
	// SETTERS

    public function set_address($new) {
		$this->CI->api->firewall->modify->standalone_rule($this->address, $this->port, $this->transport, 'address', $new);
		$this->address = $new;
	}

    public function set_port($new) {
		$this->CI->api->firewall->modify->standalone_rule($this->address, $this->port, $this->transport, 'port', $new);
		$this->port = $new;
	}

    public function set_transport($new) {
		$this->CI->api->firewall->modify->standalone_rule($this->address, $this->port, $this->transport, 'transport', $new);
		$this->transport = $new;
	}

    public function set_deny($new) {
		$this->CI->api->firewall->modify->standalone_rule($this->address, $this->port, $this->transport, 'deny', $new);
		$this->deny = $new;
	}

    public function set_owner($new) {
		$this->CI->api->firewall->modify->standalone_rule($this->address, $this->port, $this->transport, 'owner', $new);
		$this->owner = $new;
	}

    public function set_comment($new) {
		$this->CI->api->firewall->modify->standalone_rule($this->address, $this->port, $this->transport, 'comment', $new);
		$this->comment = $new;
	}

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS

	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file StandaloneRule.php */
/* Location: ./application/libraries/objects/StandaloneRule.php */