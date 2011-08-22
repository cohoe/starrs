<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_statistics_get extends ImpulseModel {

	public function os_distribution() {
		$sql = "SELECT * FROM api.get_os_distribution()";
		$query = $this->db->query($sql);
		return $query->result_array();
	}

	public function os_family_distribution() {
		$sql = "SELECT * FROM api.get_os_family_distribution()";
		$query = $this->db->query($sql);
		return $query->result_array();
	}
}
/* End of file api_statistics_get.php */
/* Location: ./application/models/API/Systems/api_statistics_get.php */