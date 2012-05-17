<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class RangeOption extends DhcpOption {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	private $range;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

    public function __construct($range, $option, $value, $dateCreated, $dateModified, $lastModifier) {
		// Chain into the parent
		parent::__construct($option, $value, $dateCreated, $dateModified, $lastModifier);
		
		// Object specific data
		$this->range = $range;
	}

	////////////////////////////////////////////////////////////////////////
	// GETTERS
	
	public function get_range() { return $this->range; }

    ////////////////////////////////////////////////////////////////////////
	// SETTERS
	
	public function set_range($new) {
		$this->CI->api->dhcp->modify->range_option($this->range, $this->option, $this->value, 'range', $new);
		$this->range = $new;
	}
	
	public function set_option($new) {
		$this->CI->api->dhcp->modify->range_option($this->range, $this->option, $this->value, 'option', $new);
		$this->option = $new;
	}
	
	public function set_value($new) {
		$this->CI->api->dhcp->modify->range_option($this->range, $this->option, $this->value, 'value', $new);
		$this->value = $new;
	}

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
    
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
/* End of file RangeOption.php */
/* Location: ./application/libraries/objects/RangeOption.php */