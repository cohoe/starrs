<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_network_list extends ImpulseModel {

	 public function systems() {
		// SQL query
		$sql = "SELECT system_name FROM api.get_systems(NULL) WHERE family = 'Network'";
		$query = $this->db->query($sql);

		// Check error
          $this->_check_error($query);

		$resultSet = array();
		foreach($query->result_array() as $result) {
			$resultSet[] = $result['system_name'];
		}

		return $resultSet;
	 }

}
/* End of file api_network_list.php */
/* Location: ./application/models/API/Network/api_network_list.php */
