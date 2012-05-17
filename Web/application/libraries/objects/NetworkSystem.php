<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "controllers/computer_system.php");

class NetworkSystem extends System {

    private $switchports;

    private $enable;

    private $snmpROCommunity;

    private $snmpRWCommunity;

    ////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
    
    public function __construct($systemName, $owner, $comment, $type, $family, $osName, $renewDate, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($systemName, $owner, $comment, $type, $family, $osName, $renewDate, $dateCreated, $dateModified, $lastModifier);

        try {
            $settings = $this->CI->api->network->get->switchview_settings($systemName);
            $this->enable = $settings['enable'];
            $this->snmpROCommunity = $settings['snmp_ro_community'];
            $this->snmpRWCommunity = $settings['snmp_rw_community'];
        }
        catch(ObjectNotFoundException $onfE) {}

	}

    ////////////////////////////////////////////////////////////////////////
	// GETTERS

    public function get_switchports()       { return $this->switchports; }
    public function get_switchview_enable() { return $this->enable; }
    public function get_ro_community()      { return $this->snmpROCommunity; }
    public function get_rw_community()      { return $this->snmpRWCommunity; }

    ////////////////////////////////////////////////////////////////////////
	// SETTERS

    public function set_ro_community($new) {
        $this->CI->api->network->modify->switchview_settings($this->get_system_name(), 'snmp_ro_community', $new);
        $this->snmpROCommunity = $new;
    }
    
    public function set_rw_community($new) {
        $this->CI->api->network->modify->switchview_settings($this->get_system_name(), 'snmp_rw_community', $new);
        $this->snmpRWCommunity = $new;
    }

    public function set_switchview_enable($new) {
        $this->CI->api->network->modify->switchview_settings($this->get_system_name(), 'enable', $new);
        $this->enable = $new;
    }

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS

    public function add_switchport($sPort) {
        if(!($sPort instanceof NetworkSwitchport)) {
            throw new ObjectException("Cannot add non-switchport as switchport");
        }

        $this->switchports[$sPort->get_port_name()] = $sPort;
    }

    public function get_switchport($portName) {
        if($this->switchports[$portName]) {
            return $this->switchports[$portName];
        }
        else {
            throw new ObjectException("No switchport found!");
        }
    }

    ////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file NetworkSystem.php */
/* Location: ./application/libraries/objects/NetworkSystem.php */
