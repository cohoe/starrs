<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class SubnetOption extends DhcpOption {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	private $subnet;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

    public function __construct($subnet, $option, $value, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($option, $value, $dateCreated, $dateModified, $lastModifier);
		
		// Object specific data
		$this->subnet = $subnet;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_subnet() { return $this->subnet; }

    ////////////////////////////////////////////////////////////////////////
	// SETTERS
	
	public function set_subnet($new) {
		$this->CI->api->dhcp->modify->subnet_option($this->subnet, $this->option, $this->value, 'subnet', $new);
		$this->subnet = $new;
	}
	
	public function set_option($new) {
		$this->CI->api->dhcp->modify->subnet_option($this->subnet, $this->option, $this->value, 'option', $new);
		$this->option = $new;
	}
	
	public function set_value($new) {
		$this->CI->api->dhcp->modify->subnet_option($this->subnet, $this->option, $this->value, 'value', $new);
		$this->value = $new;
	}

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
    
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file SubnetOption.php */
/* Location: ./application/libraries/objects/SubnetOption.php */