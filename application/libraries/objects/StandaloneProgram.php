<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * Standalone program rules
 * NOTE: You cannot modify a program rule.
 */
class StandaloneProgram extends FirewallRule {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// string	The IP address to apply the rule to
	private $address;
	
	// string	The name of the program that defines this rule
	private $programName;
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	public function __construct($address, $programName, $port, $transport, $deny, $comment, $owner, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($port, $transport, $deny, $comment, $owner, 'standalone-program', $dateCreated, $dateModified, $lastModifier);
		
		// StandaloneRule specific stuff
		$this->address = $address;
		$this->programName = $programName;
	}
	
	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_address()      { return $this->address; }
	public function get_program_name() { return $this->programName; }

    ////////////////////////////////////////////////////////////////////////
	// SETTERS

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS

	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file StandaloneProgram.php */
/* Location: ./application/libraries/objects/StandaloneProgram.php */