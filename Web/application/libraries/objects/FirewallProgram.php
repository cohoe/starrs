<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * Certain common programs were created to make your lives easier.
 */
class FirewallProgram extends ImpulseObject {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES

    // string   The name of the program
	private $name;

    // int      The port number
	private $port;

    // string   The transport of the program (TCP/UDP/BOTH)
	private $transport;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

    /**
     * @param   string  $name           The name of the program
     * @param   int     $port           The port of the program
     * @param   string  $transport      The transport (TCP/UDP/BOTH) of the program
	 * @param	long	$dateCreated	Unix timestamp when the record was created
	 * @param	long	$dateModified	Unix timestamp when the record was modified
	 * @param	string	$lastModifier	The last user to modify the record
     */
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
	// SETTERS
    
	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
	
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file FirewallProgram.php */
/* Location: ./application/libraries/objects/FirewallProgram.php */