<?php
/**
 * Class for all text (TXT, SPF) records
 */
class TxtRecord extends DnsRecord {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// string		The text to describe an existing A or AAAA record
	private $text;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	/**
	 * Construct a new TxtRecord from the given information
	 * @param	string	$hostname		The hostname of the record
	 * @param	string	$zone			The zone of the record
	 * @param	string	$address		The resolving address of the record
	 * @param	string	$type			The type of the record
	 * @param	int		$ttl			The time-to-live of the record
	 * @param	string	$owner			The owner of the record
	 * @param	string	$text			The text to place in the record
	 * @param	long	$dateCreated	Unix timestamp when the record was created
	 * @param	long	$dateModified	Unix timestamp when the record was modifed
	 * @param	string	$lastModifer	The last user to modify the record 
	 */
	public function __construct($hostname, $zone, $address, $type, $ttl, $owner, $text, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($hostname, $zone, $address, $type, $ttl, $owner, $dateCreated, $dateModified, $lastModifier);
		
		// TxtRecord-specific stuff
		$this->text = $text;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_text() { return $this->text; }
	
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
	
	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
}