<?php
/**
 *
 */
class Api_ip extends CI_Model {

    /**
     *
     */
	function __construct() {
		parent::__construct();
	}
	
	public function get_ranges() {
		$sql = "SELECT * FROM ip.ranges";
		$query = $this->db->query($sql);
		return $query->result_array();
	}
	
	public function get_address_from_range($range) {
		$sql = "SELECT api.get_address_from_range({$this->db->escape($range)})";
		$query = $this->db->query($sql);
		return $query->row()->get_address_from_range;
	}
}