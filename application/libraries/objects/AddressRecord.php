<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * Class for all regular address records (A, AAAA)
 */
class AddressRecord extends DnsRecord {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	/**
	 * @param	string	$hostname		The hostname of the record
	 * @param	string	$zone			The zone of the record
	 * @param	string	$address		The resolving address of the record
	 * @param	string	$type			The type of the record
	 * @param	int		$ttl			The time-to-live of the record
	 * @param	string	$owner			The owner of the record
	 * @param	long	$dateCreated	Unix timestamp when the record was created
	 * @param	long	$dateModified	Unix timestamp when the record was modified
	 * @param	string	$lastModifier	The last user to modify the record
	 */
	public function __construct($hostname, $zone, $address, $type, $ttl, $owner, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($hostname, $zone, $address, $type, $ttl, $owner, $dateCreated, $dateModified, $lastModifier);
	}
	
	////////////////////////////////////////////////////////////////////////
	// GETTERS

    ////////////////////////////////////////////////////////////////////////
	// SETTERS

    public function set_hostname($new) {
		$this->CI->api->dns->modify->address($this->address, $this->zone, 'hostname', $new);
		$this->hostname = $new;
	}

	public function set_zone($new) {
		$this->CI->api->dns->modify->address($this->address, $this->zone, 'zone', $new);
		$this->zone = $new;
	}

	public function set_ttl($new) {
		$this->CI->api->dns->modify->address($this->address, $this->zone, 'ttl', $new);
		$this->ttl = $new;
	}

	public function set_owner($new) {
		$this->CI->api->dns->modify->address($this->address, $this->zone, 'owner', $new);
		$this->owner = $new;
	}

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS

	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file AddressRecord.php */
/* Location: ./application/libraries/objects/AddressRecord.php */