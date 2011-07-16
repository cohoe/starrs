<?php
/**
 * DHCP
 */
class Api_dhcp extends CI_Model {
    /**
     * Constructor
     */
	function __construct() {
		parent::__construct();
	}
	
	public function get_config_types() {
		$sql = "SELECT * FROM dhcp.config_types";
		$query = $this->db->query($sql);
		return $query->result_array();
	}
	
	public function get_classes() {
		$sql = "SELECT * FROM dhcp.classes";
		$query = $this->db->query($sql);
		return $query->result_array();
	}
}
