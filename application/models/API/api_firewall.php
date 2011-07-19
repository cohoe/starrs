<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 * Firewall related information
 */
class Api_firewall extends ImpulseModel {

    /**
     * Constructor
     */
	public function __construct() {
		parent::__construct();
	}
	
	/**
     * Get all address rules that apply to a certain address
     * @param $address                  IP address to search on
     * @return array<FirewallRule>      Array of rule objects
     */
    public function get_address_rules($address) {
        // SQL Query
		$sql = "SELECT * FROM api.get_firewall_rules({$this->db->escape($address)})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

        // Generate results
        $resultSet = array();
        foreach($query->result_array() as $fwRule) {
            $resultSet[] = new FirewallRule(
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

        // Return results
        if(count($resultSet > 0)) {
            return $resultSet;
        }
        else {
			throw new ObjectNotFoundException("No firewall rules found.");
		}
	}
	
	/**
     * Get the name of a firewall program based on its port
     * @param $port     The port of the program to search on
     * @return string   The name of the program
     */
    public function get_firewall_program($port) {
        // SQL Query
		$sql = "SELECT api.get_firewall_program_name({$this->db->escape($port)})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

        // Return result
        if($query->num_rows() == 1) {
            return $query->row()->get_firewall_program_name;
        }
        elseif($query->num_rows() > 1) {
            throw new AmbiguousTargetException("Multiple program names found. This indicates a database error. Contact your system administrator");
        }
        else {
            throw new ObjectNotFoundException("No program name found");
        }

	}

    /**
     * Get the default firewall action of an address
     * @param $address  The address to search on
     * @return bool     Deny (t) the traffic or allow (f)
     */
    public function get_firewall_default($address) {
        // SQL Query
		$sql = "SELECT api.get_firewall_default({$this->db->escape($address)})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

        // Return Result
		if($query->num_rows() == 1) {
			return $query->row()->get_firewall_default;
		}
        elseif($query->num_rows() > 1) {
            throw new AmbiguousTargetException("Multiple addresses found. This indicates a database error. Contact your system administrator");
        }
        else {
            throw new ObjectNotFoundException("No address action found");
        }
	}
}

/* End of file api_firewall.php */
/* Location: ./application/models/API/api_firewall.php */