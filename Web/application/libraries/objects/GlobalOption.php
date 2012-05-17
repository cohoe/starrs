<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class GlobalOption extends DhcpOption {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

    public function __construct($option, $value, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($option, $value, $dateCreated, $dateModified, $lastModifier);
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS

    ////////////////////////////////////////////////////////////////////////
	// SETTERS
	
	public function set_option($new) {
		$this->CI->api->dhcp->modify->global_option($this->option, $this->value, 'option', $new);
		$this->option = $new;
	}
	
	public function set_value($new) {
		$this->CI->api->dhcp->modify->global_option($this->option, $this->value, 'value', $new);
		$this->value = $new;
	}

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
    
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file GlobalOption.php */
/* Location: ./application/libraries/objects/GlobalOption.php */