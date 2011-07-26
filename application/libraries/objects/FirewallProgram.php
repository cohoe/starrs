<?php
class FirewallProgram extends ImpulseObject {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	private $name;
	private $port;
	private $transport;
	

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	public function __construct($name, $port, $transport, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($dateCreated, $dateModified, $lastModifier);

		// Object specific data
		$this->name = $name;
		$this->port = $port;
        $this->transport = $transport;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
    public function get_name()	    { return $this->name; }
    public function get_port()      { return $this->port; }
    public function get_transport() { return $this->transport; }

	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
	
	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
}

/* End of file FirewallProgram.php */
/* Location: ./application/libraries/objects/FirewallProgram.php */