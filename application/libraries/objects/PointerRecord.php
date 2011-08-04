<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * Class for all pointer (CNAME, SRV) records
 */
class PointerRecord extends DnsRecord {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	// string	The pointer name
	private $alias;
	
	// string	Extra information required for certain records
	private $extra;

    // int      The priority field of a SRV record
	private $priority;

    // int      The weight field of a SRV record
	private $weight;

    // int      The port of the SRV field
	private $port;
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	/**
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
		
		// SRV records have cool extra information
		// @todo: apparently split() is deprecated. Find something else
		if($type == 'SRV') {
			list($this->priority, $this->weight, $this->port) = split(' ',$extra);
		}
	}
	
	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_alias() { return $this->alias; }
	public function get_extra() { return $this->extra; }
	public function get_priority() { return $this->priority; }
	public function get_weight()   { return $this->weight; }
	public function get_port()     { return $this->port; }

    ////////////////////////////////////////////////////////////////////////
	// SETTERS
	
	public function set_hostname($new) {
		if($this->get_type() == "CNAME") {
			$this->CI->api->dns->modify->cname($this->alias, $this->zone, 'hostname', $new);	
		}
		else {
			$this->CI->api->dns->modify->srv($this->alias, $this->zone, 'hostname', $new);	
		}
		$this->hostname = $new; 
	}
	
	public function set_zone($new) {
		if($this->get_type() == "CNAME") {
			$this->CI->api->dns->modify->cname($this->alias, $this->zone, 'zone', $new);	
		}
		else {
			$this->CI->api->dns->modify->srv($this->alias, $this->zone, 'zone', $new);	
		}
		$this->zone = $new; 
	}
	
	public function set_ttl($new) {
		if($this->get_type() == "CNAME") {
			$this->CI->api->dns->modify->cname($this->alias, $this->zone, 'ttl', $new);	
		}
		else {
			$this->CI->api->dns->modify->srv($this->alias, $this->zone, 'ttl', $new);	
		}
		$this->ttl = $new; 
	}
	
	public function set_owner($new) {
		if($this->get_type() == "CNAME") {
			$this->CI->api->dns->modify->cname($this->alias, $this->zone, 'owner', $new);	
		}
		else {
			$this->CI->api->dns->modify->srv($this->alias, $this->zone, 'owner', $new);	
		}
		$this->owner = $new; 
	}
	
	public function set_alias($new) {
		if($this->get_type() == "CNAME") {
			$this->CI->api->dns->modify->cname($this->alias, $this->zone, 'alias', $new);	
		}
		else {
			$this->CI->api->dns->modify->srv($this->alias, $this->zone, 'alias', $new);	
		}
		$this->alias = $new; 
	}
	
	public function set_extra($new) {
		if($this->get_type() == "CNAME") {
			$this->CI->api->dns->modify->cname($this->alias, $this->zone, 'extra', $new);	
		}
		else {
			$this->CI->api->dns->modify->srv($this->alias, $this->zone, 'extra', $new);	
		}
		$this->extra = $new; 
	}
	
	public function set_priority($new) {
		if($this->get_type() != "SRV") {
			throw new ObjectException("Cannot set priority of a non-SRV record");
		}
		$this->set_extra(preg_replace('/^\d+/',$new,$this->get_extra()));
	}
	
	public function set_weight($new) {
		if($this->get_type() != "SRV") {
			throw new ObjectException("Cannot set weight of a non-SRV record");
		}
		$this->set_extra(preg_replace('/ \d+ /'," $new ",$this->get_extra()));
	}
	
	public function set_port($new) {
		if($this->get_type() != "SRV") {
			throw new ObjectException("Cannot set priority of a non-SRV record");
		}
		$this->set_extra(preg_replace('/\d+$/',$new,$this->get_extra()));
	}

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS

    ////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file PointerRecord.php */
/* Location: ./application/libraries/objects/PointerRecord.php */