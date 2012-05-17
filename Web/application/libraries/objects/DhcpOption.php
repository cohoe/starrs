<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class DhcpOption extends ImpulseObject {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	protected $option;
	protected $value;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

    public function __construct($option, $value, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// Object specific data
		$this->option = $option;
		$this->value  = $value;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_option() { return $this->option; }
	public function get_value()  { return $this->value; }

    ////////////////////////////////////////////////////////////////////////
	// SETTERS

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
    
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file DhcpOption.php */
/* Location: ./application/libraries/objects/DhcpOption.php */