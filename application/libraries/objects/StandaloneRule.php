<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

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

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS

	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file StandaloneRule.php */
/* Location: ./application/libraries/objects/StandaloneRule.php */
