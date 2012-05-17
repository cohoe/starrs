<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 *	Firewall
 */
class Api_firewall_remove extends ImpulseModel {
	
	public function metahost_member($membr) {
		// SQL Query
		$sql = "SELECT api.remove_firewall_metahost_member({$this->db->escape($membr->get_address())})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
	}
	
	public function metahost($mHost) {
		// SQL Query
		$sql = "SELECT api.remove_firewall_metahost({$this->db->escape($mHost->get_name())})";
		$query = $this->db->query($sql);

		
        // Check error
        $this->_check_error($query);
	}
	
	 public function metahost_rule($metahostName, $port, $transport) {
		// SQL Query
		$sql = "SELECT api.remove_firewall_metahost_rule(
			{$this->db->escape($metahostName)},
			{$this->db->escape($port)},
			{$this->db->escape($transport)}
		)";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
	}
	
	// @todo: Firewall device address
	
	public function standalone_rule($address, $port, $transport) {
		// SQL Query
		$sql = "SELECT api.remove_firewall_rule(
			{$this->db->escape($address)},
			{$this->db->escape($port)},
			{$this->db->escape($transport)}
		)";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
	}
	
	public function standalone_program($address, $program) {
		// SQL Query
		$sql = "SELECT api.remove_firewall_rule_program(
			{$this->db->escape($address)},
			{$this->db->escape($program)}
		)";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
	}

	public function metahost_program_rule($metahostName, $programName) {
		// SQL Query
		$sql = "SELECT api.remove_firewall_metahost_rule_program(
			{$this->db->escape($metahostName)},
			{$this->db->escape($programName)}
		)";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
	}
}
/* End of file api_firewall_remove.php */
/* Location: ./application/models/API/DNS/api_firewall_remove.php */