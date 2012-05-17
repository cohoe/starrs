<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 *	Firewall
 */
class Api_firewall_modify extends ImpulseModel {
	
	public function _default($address, $action) {
		// SQL Query
		$sql = "SELECT api.modify_firewall_default(
			{$this->db->escape($address)},
			{$this->db->escape($action)}
		)";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
	}
	
	public function metahost($metahostName, $field, $newValue) {
        // SQL Query
        $sql = "SELECT api.modify_firewall_metahost(
            {$this->db->escape($metahostName)},
            {$this->db->escape($field)},
            {$this->db->escape($newValue)}
        )";
        $query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
    }
	
	public function standalone_rule($address, $port, $transport, $field, $value) {
		// SQL Query
		$sql = "SELECT api.modify_firewall_rule(
			{$this->db->escape($address)},
			{$this->db->escape($port)},
			{$this->db->escape($transport)},
			{$this->db->escape($field)},
			{$this->db->escape($value)}
		)";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
	}
	
	public function metahost_rule($metahostName, $port, $transport, $field, $value) {
		// SQL Query
		$sql = "SELECT api.modify_firewall_metahost_rule(
			{$this->db->escape($metahostName)},
			{$this->db->escape($port)},
			{$this->db->escape($transport)},
			{$this->db->escape($field)},
			{$this->db->escape($value)}
		)";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
	}
	
	// @todo: Firewall device address
}
/* End of file api_firewall_modify.php */
/* Location: ./application/models/API/DNS/api_firewall_modify.php */