<?php
/**
 * DHCP configuration type
 */
class ConfigType extends ImpulseObject {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	private $config;
	private $comment;
	private $family;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	public function __construct($config, $comment, $family, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// Object specific data
		$this->config = $config;
		$this->comment = $comment;
		$this->family = $family;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_config()	{ return $this->config; }
	public function get_comment()	{ return $this->comment; }
	public function get_family()	{ return $this->family; }
	
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
	
	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
}

/* End of file ConfigType.php */
/* Location: ./application/libraries/objects/ConfigType.php */