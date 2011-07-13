<?php
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
	 * Construct a new MxRecord from the given information
	 * @param	string	$hostname		The hostname of the record
	 * @param	string	$zone			The zone of the record
	 * @param	string	$address		The resolving address of the record
	 * @param	string	$type			The type of the record
	 * @param	int		$ttl			The time-to-live of the record
	 * @param	string	$owner			The owner of the record
	 * @param	int		$preference		The preference of the server
	 * @param	long	$dateCreated	Unix timestamp when the record was created
	 * @param	long	$dateModified	Unix timestamp when the record was modifed
	 * @param	string	$lastModifer	The last user to modify the record 
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
	// PRIVATE METHODS
	
	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
}