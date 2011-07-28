<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "controllers/firewall.php");

class FirewallRule extends ImpulseObject {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// int		The port to apply to
	private $port;
	
	// string	The transport protocol (layer 4) of the rule
	private $transport;
	
	// bool		Deny or allow the traffic on the port/transport
	private $deny;
	
	// string	A comment on the rule
	private $comment;
	
	// string	The owner of the rule. You can apply rules to systems you do not own if you are an admin
	private $owner;
	
	// string	The source of the rule (metahost, program, standalone, etc)
	private $source;
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	public function __construct($port, $transport, $deny, $comment, $owner, $source, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// FirewallRule specific stuff
		$this->port      = $port;
		$this->transport = $transport;
		$this->deny      = $deny;
		$this->comment   = $comment;
		$this->owner     = $owner;
		$this->source    = $source;
	}
	
	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_port()          { return $this->port; }
	public function get_transport()     { return $this->transport; }
	public function get_deny()          { return $this->deny; }
	public function get_owner()         { return $this->owner; }
	public function get_source()        { return $this->source; }
	public function get_comment()       { return $this->comment; }

    ////////////////////////////////////////////////////////////////////////
	// SETTERS

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS

	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file FirewallRule.php */
/* Location: ./application/libraries/objects/FirewallRule.php */