<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Switchport extends ImpulseObject {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	private $portName;
	private $description;
	private $type;
	private $attachedMac;
	private $systemName;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

    public function __construct($portName, $description, $type, $attachedMac, $systemName, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// Object specific data
		$this->portName    = $portName;
		$this->description = $description;
		$this->type        = $type;
		$this->attachedMac = $attachedMac;
		$this->systemName  = $systemName;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_port_name()    { return $this->portName; }
	public function get_description()  { return $this->description; }
	public function get_type()         { return $this->type; }
	public function get_attached_mac() { return $this->attachedMac; }
	public function get_system_name()  { return $this->systemName; }

    ////////////////////////////////////////////////////////////////////////
	// SETTERS
	
	public function set_port_name($new) {
		$this->CI->api->network->modify->switchport($this->systemName, $this->portName, 'port_name', $new);
		$this->portName = $new;
	}
	
	public function set_description($new) {
		$this->CI->api->network->modify->switchport($this->systemName, $this->portName, 'description', $new);
		$this->description = $new;
	}
	
	public function set_type($new) {
		$this->CI->api->network->modify->switchport($this->systemName, $this->portName, 'type', $new);
		$this->type = $new;
	}

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
    
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file Switchport.php */
/* Location: ./application/libraries/objects/Switchport.php */