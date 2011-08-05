<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * DHCP configuration class
 */
class ConfigClass extends ImpulseObject {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES

    // string   The name of the class
	private $class;

    // string   A comment on the class
	private $comment;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

    /**
     * @param   string  $class          The name of the class
     * @param   string  $comment        A comment on the class
	 * @param	long	$dateCreated	Unix timestamp when the record was created
	 * @param	long	$dateModified	Unix timestamp when the record was modified
	 * @param	string	$lastModifier	The last user to modify the record
     */
    public function __construct($class, $comment, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// Object specific data
		$this->class = $class;
		$this->comment = $comment;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_class()	    { return $this->class; }
	public function get_comment()	{ return $this->comment; }

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
/* End of file ConfigClass.php */
/* Location: ./application/libraries/objects/ConfigClass.php */