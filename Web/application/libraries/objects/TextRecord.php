<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * Class for all text (TXT, SPF) records
 */
class TextRecord extends DnsRecord {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// string		The text to describe an existing A or AAAA record
	private $text;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	/**
	 * @param	string	$hostname		The hostname of the record
	 * @param	string	$zone			The zone of the record
	 * @param	string	$address		The resolving address of the record
	 * @param	string	$type			The type of the record
	 * @param	int		$ttl			The time-to-live of the record
	 * @param	string	$owner			The owner of the record
	 * @param	string	$text			The text to place in the record
	 * @param	long	$dateCreated	Unix timestamp when the record was created
	 * @param	long	$dateModified	Unix timestamp when the record was modified
	 * @param	string	$lastModifier	The last user to modify the record
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
	// SETTERS

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS

	public function set_hostname($new) {
		$this->CI->api->dns->modify->text($this->hostname, $this->zone, 'hostname', $new);
		$this->hostname = $new;
	}

	public function set_zone($new) {
		$this->CI->api->dns->modify->text($this->hostname, $this->zone, 'zone', $new);
		$this->zone = $new;
	}

	public function set_ttl($new) {
		$this->CI->api->dns->modify->text($this->hostname, $this->zone, 'ttl', $new);
		$this->ttl = $new;
	}

	public function set_owner($new) {
		$this->CI->api->dns->modify->text($this->hostname, $this->zone, 'owner', $new);
		$this->owner = $new;
	}

	public function set_text($new) {
		$this->CI->api->dns->modify->text($this->hostname, $this->zone, $this->type, 'text', $new);
		$this->owner = $new;
	}
    
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file TextRecord.php */
/* Location: ./application/libraries/objects/TextRecord.php */