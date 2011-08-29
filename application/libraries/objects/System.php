<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * This class contains the definition for a the System object. A system is 
 * essentially a server/machine that is part of the network.
 */
class System extends ImpulseObject {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// string	A descriptive comment about the system
	private $comment;
	
	// bool		Whether or not the system is complete (contains interfaces)
	private $hasInterfaces;
	
	// array<InterfaceObjects>	The interfaces associated with the system
	private $interfaces;
	
	// string	The OS that the system is running
	private $osName;
	
	// string	The user who owns the system
	private $owner;
	
	// long		The date the system was renewed, stored as a Unix timestamp
	private $renewDate;
	
	// string	The name of the system
	private $systemName;
	
	// string	The type of system
	private $type;

    // string   The family of the type of system
    private $family;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	/**
	 * @param	string	$systemName		The name of the system to create
	 * @param	string	$owner			The owning username of the system
	 * @param	string	$comment		A comment on the system
	 * @param	string	$type			The type of system
     * @param	string	$family			The family of the type of system
	 * @param	string	$osName			The name of the primary operating system
	 * @param	long	$renewDate		The date the system needs renewed on
	 * @param	long	$dateCreated	Unix timestamp when the record was created
	 * @param	long	$dateModified	Unix timestamp when the record was modifed
	 * @param	string	$lastModifier	The last user to modify the record
	 */
	public function __construct($systemName, $owner, $comment, $type, $family, $osName, $renewDate, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// Store the rest of the data
		$this->systemName 	= $systemName;
		$this->owner 		= $owner;
		$this->comment 		= $comment;
		$this->type			= $type;
        $this->family		= $family;
		$this->osName		= $osName;
		$this->renewDate	= $renewDate; 
		
		// Initialize other vars
		$this->hasInterfaces = false;
		$this->interfaces = array();
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_system_name()   { return $this->systemName; }
	public function get_owner()         { return $this->owner; }
	public function get_comment()       { return $this->comment; }
	public function get_renew_date()    { return $this->renewDate; }
	public function get_type()          { return $this->type; }
    public function get_family()        { return $this->family; }
	public function get_os_name()       { return $this->osName; }
	public function get_interfaces()    { return $this->interfaces; }
    
	////////////////////////////////////////////////////////////////////////
	// SETTERS
	
	public function set_system_name($new) {
		$this->CI->api->systems->modify->system($this->systemName, 'system_name', $new);	
		$this->systemName = $new; 
	}
	
	public function set_owner($new) { 
		$this->CI->api->systems->modify->system($this->systemName, 'owner', $new);
		$this->owner = $new; 
	}
	
	public function set_comment($new) { 
		$this->CI->api->systems->modify->system($this->systemName, 'comment', $new);
		$this->comment = $new; 
	}
	
	public function set_type($new) { 
		$this->CI->api->systems->modify->system($this->systemName, 'type', $new);
		$this->type = $new; 
	}
	
	public function set_os_name($new) { 
		$this->CI->api->systems->modify->system($this->systemName, 'os_name', $new);
		$this->osName = $new; 
	}

	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
	
	public function add_interface($interface) {
		// If it's not an interface, blow up
		if(!($interface instanceof NetworkInterface)) {
			throw new ObjectException("Cannot add a non-interface as an interface");
		}
		
		// Add an interface to the local interfaces array
		$this->interfaces[$interface->get_mac()] = $interface;
		$this->hasInterfaces = true;
	}



    public function get_interface($mac) {
        // Return the interface object that corresponds to the given MAC address
		if(!isset($this->interfaces[$mac])) {
			throw new ObjectException("No interface found!");
		}
		else {
			return $this->interfaces[$mac];
		}
    }
	
	public function get_address($address) {
		foreach($this->interfaces as $int) {
			try {
				$addr = $int->get_address($address);
				if($addr instanceof InterfaceAddress) {
					break;
				}
			}
			catch (ObjectException $oE) {
				$addr = NULL;
			}
		}
		if($addr==NULL) {
			throw new ObjectException("Unable to locate address $address on system ".$this->get_system_name());
		}
		return $addr;
    }


	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file System.php */
/* Location: ./application/libraries/objects/System.php */
