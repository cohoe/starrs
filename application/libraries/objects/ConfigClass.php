<?php
/**
 * DHCP configuration class
 */
class ConfigClass extends ImpulseObject {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	private $class;
	private $comment;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	public function __construct($class, $comment, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// Object specific data
		$this->class = $class;
		$this->comment = $comment;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_class()	{ return $this->class; }
	public function get_comment()	{ return $this->comment; }
	
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
	
	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
}

/* End of file ConfigClass.php */
/* Location: ./application/libraries/objects/ConfigClass.php */