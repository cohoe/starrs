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

    public function range_utilization($range) {
		$sql = "SELECT * FROM api.get_range_utilization() WHERE name = {$this->db->escape($range)}";
		$query = $this->db->query($sql);
		#return $query->result_array();
		return $query->row_array();
	}

    public function subnet_utilization($subnet) {
		$sql = "SELECT * FROM api.get_subnet_utilization() WHERE subnet = {$this->db->escape($subnet)}";
		$query = $this->db->query($sql);
		#return $query->result_array();
		return $query->row_array();
	}
}
/* End of file api_statistics_get.php */
/* Location: ./application/models/API/Systems/api_statistics_get.php */
