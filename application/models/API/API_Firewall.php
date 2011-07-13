<?php
class Api_firewall extends CI_Model {
	
	public function __construct() {
		parent::__construct();
	}
	
	/**
     * @param $address
     * @return array
     */
    public function get_address_rules($address) {
		$sql = "SELECT * FROM api.get_firewall_rules({$this->db->escape($address)})";
		$query = $this->db->query($sql);

        $ruleSet = array();

        foreach($query->result_array() as $fwRule) {
            $ruleSet[] = new FirewallRule(
                $fwRule['port'],
                $fwRule['transport'],
                $fwRule['deny'],
                $fwRule['comment'],
                $fwRule['address'],
                $fwRule['owner'],
                $fwRule['source'],
                $fwRule['date_created'],
                $fwRule['date_modified'],
                $fwRule['last_modifier']
            );
        }

        // Return the array of rules
        return $ruleSet;
	}
	
	/**
     * Get the name of a firewall program based on its port
     * @param $port     The port of the program to search on
     * @return string   The name of the program
     */
    public function get_firewall_program($port) {
		$sql = "SELECT api.get_firewall_program_name({$this->db->escape($port)})";
		$query = $this->db->query($sql);
		return $query->row()->get_firewall_program_name;
	}

    /**
     * Get the default firewall action of an address
     * @param $address  The address to search on
     * @return bool     Deny (t) the traffic or allow (f)
     * @todo: add exceptions for non 1 results
     */
    public function get_firewall_default($address) {
		$sql = "SELECT api.get_firewall_default({$this->db->escape($address)})";
		$query = $this->db->query($sql);
		if($query->num_rows() == 1) {
			return $query->row()->get_firewall_default;
		}
	}
}