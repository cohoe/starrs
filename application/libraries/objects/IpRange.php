<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * IP address range for DHCP and address selection use
 */
class IpRange extends ImpulseObject {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES

    // string   The first IP address in the range
	private $firstIp;

    // string   The last IP address in the range
    private $lastIp;

    // string   A use code for the range
    private $use;

    // string   The name of the range
    private $name;

    // string   The subnet that contains the range
    private $subnet;

    // string   The DHCP class of the range
    private $class;

    // string   A comment on the range
    private $comment;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

    /**
     * @param   string  $firstIp        The first IP address of the range
     * @param   string  $lastIp         The last IP address of the range
     * @param   string  $use            The use code for the range
     * @param   string  $name           The name of the range
     * @param   string  $subnet         Subnet containing the range
     * @param   string  $class          DHCP class of the range
     * @param   string  $comment        A comment on the range
	 * @param	long	$dateCreated	Unix timestamp when the address was created
	 * @param	long	$dateModified	Unix timestamp when the address was modified
	 * @param	string	$lastModifier	The last user to modify the address
     */
    public function __construct($firstIp, $lastIp, $use, $name, $subnet, $class, $comment, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);
		
		// Object specific data
		$this->firstIp = $firstIp;
		$this->lastIp = $lastIp;
        $this->use = $use;
        $this->name = $name;
        $this->subnet = $subnet;
        $this->class = $class;
        $this->comment = $comment;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_first_ip()	{ return $this->firstIp; }
    public function get_last_ip()	{ return $this->lastIp; }
    public function get_use()	    { return $this->use; }
    public function get_name()	    { return $this->name; }
    public function get_subnet()    { return $this->subnet; }
    public function get_class()	    { return $this->class; }
    public function get_comment()	{ return $this->comment; }

    ////////////////////////////////////////////////////////////////////////
	// SETTERS
	
	public function set_first_ip($new) {
		$this->CI->api->ip->modify->range($this->name, 'first_ip', $new);
		$this->firstIp = $new;
	}
	
	public function set_last_ip($new) {
		$this->CI->api->ip->modify->range($this->name, 'last_ip', $new);
		$this->lastIp = $new;
	}
	
	public function set_use($new) {
		$this->CI->api->ip->modify->range($this->name, 'use', $new);
		$this->use = $new;
	}
	
	public function set_name($new) {
		$this->CI->api->ip->modify->range($this->name, 'name', $new);
		$this->name = $new;
	}
	
	public function set_subnet($new) {
		$this->CI->api->ip->modify->range($this->name, 'subnet', $new);
		$this->subnet = $new;
	}
	
	public function set_class($new) {
		$this->CI->api->ip->modify->range($this->name, 'class', $new);
		$this->class = $new;
	}
	
	public function set_comment($new) {
		$this->CI->api->ip->modify->range($this->name, 'comment', $new);
		$this->comment = $new;
	}

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
    
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file IpRange.php */
/* Location: ./application/libraries/objects/IpRange.php */