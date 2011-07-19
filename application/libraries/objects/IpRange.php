<?php
/**
 * IP address range for DHCP and address selection use
 */
class IpRange extends ImpulseObject {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	private $firstIp;
    private $lastIp;
    private $use;
    private $name;
    private $subnet;
    private $class;
    private $comment;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
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
	// PRIVATE METHODS
	
	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
}

/* End of file IpRange.php */
/* Location: ./application/libraries/objects/IpRange.php */