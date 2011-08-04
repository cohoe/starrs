<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class ClassOption extends DhcpOption {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	private $class;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

    public function __construct($class, $option, $value, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($option, $value, $dateCreated, $dateModified, $lastModifier);
		
		// Object specific data
		$this->class = $class;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_class() { return $this->class; }

    ////////////////////////////////////////////////////////////////////////
	// SETTERS
	
	public function set_class($new) {
		$this->CI->api->dhcp->modify->class_option($this->class, $this->option, $this->value, 'class', $new);
		$this->class = $new;
	}
	
	public function set_option($new) {
		$this->CI->api->dhcp->modify->class_option($this->class, $this->option, $this->value, 'option', $new);
		$this->option = $new;
	}
	
	public function set_value($new) {
		$this->CI->api->dhcp->modify->class_option($this->class, $this->option, $this->value, 'value', $new);
		$this->value = $new;
	}

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
    
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file ClassOption.php */
/* Location: ./application/libraries/objects/ClassOption.php */