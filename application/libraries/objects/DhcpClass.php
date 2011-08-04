<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class DhcpClass extends ImpulseObject {

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
		$this->class   = $class;
		$this->comment = $comment;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_class()   { return $this->class; }
	public function get_comment() { return $this->comment; }

    ////////////////////////////////////////////////////////////////////////
	// SETTERS

	public function set_class($new) {
		$this->CI->api->dhcp->modify->_class($this->class, 'class', $new);
		$this->class = $new;
	}
	
	public function set_comment($new) {
		$this->CI->api->dhcp->modify->_class($this->class, 'comment', $new);
		$this->comment = $new;
	}
	
    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
    
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file DhcpClass.php */
/* Location: ./application/libraries/objects/DhcpClass.php */