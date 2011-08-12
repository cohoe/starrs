<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 *	DHCP Get
 */
class Api_dhcp_list extends ImpulseModel {
	
	public function classes() {
		// SQL Query
		$sql = "SELECT class FROM api.get_dhcp_classes()";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
		
		$resultSet = array();
		foreach($query->result_array() as $result) {
			$resultSet[] = $result['class'];
		}
		
		return $resultSet;
	}
}
/* End of file api_dhcp_list.php */
/* Location: ./application/models/API/DHCP/api_dhcp_list.php */