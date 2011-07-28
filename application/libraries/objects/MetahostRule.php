<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

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

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS

	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file MetahostRule.php */
/* Location: ./application/libraries/objects/MetahostRule.php */
