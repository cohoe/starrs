<?php

/**
 * Here we have our template for a firewall rule. A rule is pulled from the firewall.rules
 * table and applies to a certain address.
 */
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
	
	// string	The IP address to apply the rule to
	private $address;
	
	// string	The owner of the rule. You can apply rules to systems you do not own if you are an admin
	private $owner;
	
	// string	The source of the rule (metahost, program, standalone, etc)
	private $source;
	
	// string	If this rule was applied from a program template, get the name of the program. 
	private $programName;
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	/**
	 * Construct a new FirewallRule from the given information
	 * @param 	int 	$port		The port to apply to 
	 * @param	string	$transport	The transport (layer 4) of the rule
	 * @param	bool	$deny		The action of the rule
	 * @param	string	$comment	A comment on the rule
	 * @param	string	$address	The address to apply the rule to
	 * @param	string	$owner		The owner of the rule
	 * @param	string	$source		The source of the rule
	 * @param	long	$dateCreated	Unix timestamp when the rule was created
	 * @param	long	$dateModified	Unix timestamp when the rule was modifed
	 * @param	string	$lastModifier	The last user to modify the rule
	 */
	public function __construct($port, $transport, $deny, $comment, $address, $owner, $source, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// FirewallRule specific stuff
		$this->port      = $port;
		$this->transport = $transport;
		$this->deny      = $deny;
		$this->comment   = $comment;
		$this->address   = $address;
		$this->owner     = $owner;
		$this->source    = $source;
		
		// If this rule came from a program, get the name and store it locally
		if(preg_match("/program/",$this->source)) {
			$this->programName = $this->CI->api->firewall->get_firewall_program($this->port);
		}
		else {
			$this->programName = "Unknown";
		}
	}
	
	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_port()          { return $this->port; }
	public function get_transport()     { return $this->transport; }
	public function get_deny()          { return $this->deny; }
	public function get_owner()         { return $this->owner; }
	public function get_source()        { return $this->source; }
	public function get_comment()       { return $this->comment; }
	public function get_address()       { return $this->address; }
	public function get_program_name()  { return $this->programName; }
	
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
	
	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
}

/* End of file FirewallRule.php */
/* Location: ./application/libraries/objects/FirewallRule.php */