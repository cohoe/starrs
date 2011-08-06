<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_network_get extends ImpulseModel {

    public function switchports($systemName) {
		// SQL Query
        exit("Not ready");
		$sql = "SELECT * FROM api.get_network_({$this->db->escape($family)})";
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
}
/* End of file api_network_get.php */
/* Location: ./application/models/API/Network/api_network_get.php */