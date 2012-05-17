<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * This class is the template for all DNS records. It also brings in the
 * properties of an ImpulseObject.
 */
abstract class DnsRecord extends ImpulseObject {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// string	Hostname of the record (just the server name)
	protected $hostname;
	
	// string	The zone of the record
	protected $zone;
	
	// string	The resolving address of the record
	protected $address;
	
	// string	The record type (A, AAAA, SRV, etc)
	protected $type;
	
	// int		The time-to-live attribute of the record
	protected $ttl;
	
	// string	The owner of the record since shared zones can have several users
	protected $owner;
	
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
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// DnsRecord specific stuff
		$this->hostname = $hostname;
		$this->address = $address;
		$this->zone = $zone;
		$this->owner = $owner;
		$this->ttl = $ttl;
		$this->last_modifier = $lastModifier;
		$this->date_created = $dateCreated;
		$this->date_modified = $dateModified;
		$this->type = $type;
	}
	
	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_hostname() { return $this->hostname; }
	public function get_address()  { return $this->address; }
	public function get_zone()     { return $this->zone; }
	public function get_owner()    { return $this->owner; }
	public function get_ttl()      { return $this->ttl; }
	public function get_type()     { return $this->type; }
	
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
	
	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
}
/* End of file DnsRecord.php */
/* Location: ./application/libraries/objects/DnsRecord.php */