<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class NetworkSwitchport extends ImpulseObject {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES

    private $systemName;
	private $portName;
	private $description;
	private $type;
    private $portState;
    private $adminState;
	private $macAddresses;
    private $state;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

    public function __construct($systemName, $portName, $type, $description, $portState, $adminState, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// Object specific data
        $this->systemName  = $systemName;
		$this->portName    = $portName;
        $this->type        = $type;
		$this->description = $description;
		$this->portState   = $portState;
        $this->adminState  = $adminState;
		$this->systemName  = $systemName;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS

    public function get_system_name()   { return $this->systemName; }
	public function get_port_name()     { return $this->portName; }
    public function get_type()          { return $this->type; }
	public function get_description()   { return $this->description; }
	public function get_port_state()    { return $this->portState; }
    public function get_admin_state()   { return $this->adminState; }
    public function get_state()         { return $this->state; }
    public function get_mac_addresses() { return $this->macAddresses; }

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

    public function set_admin_state($new) {
		$this->CI->api->network->modify->switchport_admin_state($this->systemName, $this->portName, $new);
		$this->adminState = $new;
	}

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
	
	public function add_mac_address($macaddr) {
        $this->macAddresses[] = $macaddr;
    }
    
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file NetworkSwitchport.php */
/* Location: ./application/libraries/objects/NetworkSwitchport.php */