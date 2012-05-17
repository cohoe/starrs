<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * Class for all Mail-Exchange (MX) records
 */
class MxRecord extends DnsRecord {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// int		preference of the record (lower is higher preference)
	private $preference;
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	/**
	 * @param	string	$hostname		The hostname of the record
	 * @param	string	$zone			The zone of the record
	 * @param	string	$address		The resolving address of the record
	 * @param	string	$type			The type of the record
	 * @param	int		$ttl			The time-to-live of the record
	 * @param	string	$owner			The owner of the record
	 * @param	int		$preference		The preference of the server
	 * @param	long	$dateCreated	Unix timestamp when the record was created
	 * @param	long	$dateModified	Unix timestamp when the record was modified
	 * @param	string	$lastModifier	The last user to modify the record
	 */
	public function __construct($hostname, $zone, $address, $type, $ttl, $owner, $preference, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($hostname, $zone, $address, $type, $ttl, $owner, $dateCreated, $dateModified, $lastModifier);
		
		// MxRecord-specific stuff
		$this->preference = $preference;
	}
	
	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_preference() { return $this->preference; }

    ////////////////////////////////////////////////////////////////////////
	// SETTERS

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS

	public function set_hostname($new) {
		$this->CI->api->dns->modify->mailserver($this->hostname, $this->zone, 'hostname', $new);
		$this->hostname = $new;
	}

	public function set_zone($new) {
		$this->CI->api->dns->modify->mailserver($this->hostname, $this->zone, 'zone', $new);
		$this->zone = $new;
	}

	public function set_ttl($new) {
		$this->CI->api->dns->modify->mailserver($this->hostname, $this->zone, 'ttl', $new);
		$this->ttl = $new;
	}

	public function set_owner($new) {
		$this->CI->api->dns->modify->mailserver($this->hostname, $this->zone, 'owner', $new);
		$this->owner = $new;
	}

	public function set_preference($new) {
		$this->CI->api->dns->modify->mailserver($this->hostname, $this->zone, 'preference', $new);
		$this->owner = $new;
	}
    
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file MxRecord.php */
/* Location: ./application/libraries/objects/MxRecord.php */