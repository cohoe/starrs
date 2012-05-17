<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * Standalone metahost rules
 */
class MetahostRule extends FirewallRule {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// string	The metahost to apply the rule to
	private $metahostName;
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	public function __construct($metahostName, $port, $transport, $deny, $comment, $owner, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($port, $transport, $deny, $comment, $owner, 'metahost-standalone', $dateCreated, $dateModified, $lastModifier);
		
		// StandaloneRule specific stuff
		$this->metahostName = $metahostName;
	}
	
	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_metahost_name() { return $this->metahostName; }

    ////////////////////////////////////////////////////////////////////////
	// SETTERS

    public function set_metahost_name($new) {
		$this->CI->api->firewall->modify->metahost_rule($this->metahostName, $this->port, $this->transport, 'name', $new);
		$this->address = $new;
	}

    public function set_deny($new) {
        $this->CI->api->firewall->modify->metahost_rule($this->metahostName, $this->port, $this->transport, 'deny', $new);
		$this->deny = $new;
    }

    public function set_transport($new) {
        $this->CI->api->firewall->modify->metahost_rule($this->metahostName, $this->port, $this->transport, 'transport', $new);
		$this->transport = $new;
    }

    public function set_port($new) {
        $this->CI->api->firewall->modify->metahost_rule($this->metahostName, $this->port, $this->transport, 'port', $new);
		$this->port = $new;
    }

    public function set_comment($new) {
        $this->CI->api->firewall->modify->metahost_rule($this->metahostName, $this->port, $this->transport, 'comment', $new);
		$this->comment = $new;
    }

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS

	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file MetahostRule.php */
/* Location: ./application/libraries/objects/MetahostRule.php */
