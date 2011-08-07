<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_network_get extends ImpulseModel {

    public function switchports($systemName) {
		// SQL Query
		$sql = "SELECT * FROM api.get_network_switchports({$this->db->escape($systemName)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		// Generate results
		$resultSet = array();
		foreach($query->result_array() as $port) {
			$resultSet[] = new NetworkSwitchport(
                $port['system_name'],
				$port['port_name'],
                $port['type'],
				$port['description'],
                $port['port_state'],
                $port['admin_state'],
				$port['date_created'],
				$port['date_modified'],
				$port['last_modifier']
			);
		}

		// Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No switchports found!");
		}
	}

    public function types() {
        // SQL Query
        $sql = "SELECT api.get_network_switchport_types()";
        $query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		// Generate results
		$resultSet = array();
		foreach($query->result_array() as $type) {
			$resultSet[] = $type['get_network_switchport_types'];
		}

        // Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No switchport types found. This is a big problem. Talk to your administrator.");
		}
    }
}
/* End of file api_network_get.php */
/* Location: ./application/models/API/Network/api_network_get.php */