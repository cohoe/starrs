<?php
/*
 * Class for all Nameserver (NS) records
 */
class NsRecord extends DnsRecord {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// bool		Is this the primary nameserver for the zone?
	private $isPrimary;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	/**
	 * Construct a new NsRecord from the given information
	 * @param	string	$hostname		The hostname of the record
	 * @param	string	$zone			The zone of the record
	 * @param	string	$address		The resolving address of the record
	 * @param	string	$type			The type of the record
	 * @param	int		$ttl			The time-to-live of the record
	 * @param	string	$owner			The owner of the record
	 * @param	bool	$isPrimary		Is this nameserver the primary for the zone?
	 * @param	long	$dateCreated	Unix timestamp when the record was created
	 * @param	long	$dateModified	Unix timestamp when the record was modifed
	 * @param	string	$lastModifer	The last user to modify the record 
	 */
	public function __construct($hostname, $zone, $address, $type, $ttl, $owner, $isPrimary, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($hostname, $zone, $address, $type, $ttl, $owner, $dateCreated, $dateModified, $lastModifier);
		
		// NsRecord-specific stuff
		$this->isPrimary = $isPrimary;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_isprimary() { return $this->isprimary; }
	
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
	
	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
}