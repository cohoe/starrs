<?php
/**
 * Class for all pointer (CNAME, SRV) records
 */
class PointerRecord extends DnsRecord {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// string		The pointer name
	private $alias;
	
	// string		Extra information required for certain records
	private $extra;
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	/**
	 * Construct a new PointerRecord from the given information
	 * @param	string	$hostname		The hostname of the record
	 * @param	string	$zone			The zone of the record
	 * @param	string	$address		The resolving address of the record
	 * @param	string	$type			The type of the record
	 * @param	int		$ttl			The time-to-live of the record
	 * @param	string	$owner			The owner of the record
	 * @param	string	$alias			The alias hostname of the record
	 * @param	string	$extra			Extra information required by the record
	 * @param	long	$dateCreated	Unix timestamp when the record was created
	 * @param	long	$dateModified	Unix timestamp when the record was modifed
	 * @param	string	$lastModifier	The last user to modify the record
	 */
	public function __construct($hostname, $zone, $address, $type, $ttl, $owner, $alias, $extra, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($hostname, $zone, $address, $type, $ttl, $owner, $dateCreated, $dateModified, $lastModifier);
		
		// PointerRecord-specific stuff
		$this->alias = $alias;
		$this->extra = $extra;
	}
	
	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_alias() { return $this->alias; }
	public function get_extra() { return $this->extra; }
	
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
	
	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
}

/* End of file PointerRecord.php */
/* Location: ./application/libraries/objects/PointerRecord.php */