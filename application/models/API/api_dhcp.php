<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 * DHCP
 */
class Api_dhcp extends ImpulseModel {

    /**
     * Constructor
     */
	public function __construct() {
		parent::__construct();
	}

    /**
     * Get an array of ConfigType objects for address configuration
     * @param null $family          The address family (4, 6, 0 (both))
     * @return array<ConfigType>    Configuration types for your family
     */
    public function get_dhcp_config_types($family=NULL) {
	
		// SQL Query
		$sql = "SELECT * FROM api.get_dhcp_config_types({$this->db->escape($family)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		// Generate results
		$resultSet = array();
		foreach($query->result_array() as $configType) {
			$resultSet[] = new ConfigType(
				$configType['config'],
				$configType['comment'],
				$configType['family'],
				$configType['date_created'],
				$configType['date_modified'],
				$configType['last_modifier']
			);
		}
		
		// Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No DHCP config types found. This is a big problem. Talk to your administrator.");
		}
	}

    /**
     * Get an array of all DHCP class objects
     * @return array<string>    Array of class objects
     */
    public function get_dhcp_classes() {
	
		// SQL Query
		$sql = "SELECT * FROM api.get_dhcp_classes()";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		// Generate results
		$resultSet = array();
		foreach($query->result_array() as $class) {
			$resultSet[] = new ConfigClass(
				$class['class'],
				$class['comment'],
				$class['date_created'],
				$class['date_modified'],
				$class['last_modifier']
			);
		}
		
		// Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No DHCP classes found. This is a big problem. Talk to your administrator.");
		}
	}
}

/* End of file api_dhcp.php */
/* Location: ./application/models/API/api_dhcp.php */