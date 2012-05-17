<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * Metahost program rules.
 * NOTE: You cannot modify these rules since you either create or delete the program, nothing more.
 */
class MetahostProgram extends FirewallRule {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// string	The metahost to apply the rule to
	private $metahostName;
	
	// string	The name of the program that defines this rule
	private $programName;
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	public function __construct($metahostName, $programName, $port, $transport, $deny, $comment, $owner, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($port, $transport, $deny, $comment, $owner, 'metahost-program', $dateCreated, $dateModified, $lastModifier);
		
		// StandaloneRule specific stuff
		$this->metahostName = $metahostName;
		$this->programName = $programName;
	}
	
	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_metahost_name() { return $this->metahostName; }
	public function get_program_name() { return $this->programName; }

    ////////////////////////////////////////////////////////////////////////
	// SETTERS

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS

	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file MetahostProgram.php */
/* Location: ./application/libraries/objects/MetahostProgram.php */