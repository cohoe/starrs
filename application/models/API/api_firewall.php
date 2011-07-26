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
	
	public function get_transports() {
		// SQL Query
		$sql = "SELECT api.get_firewall_transports()";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
		
		// Generate results
        $resultSet = array();
		foreach($query->result_array() as $transport) {
			$resultSet[] = $transport['get_firewall_transports'];
		}
		
		// Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No firewall transports found. This is a big problem. Talk to your administrator.");
		}
	}
	
	public function get_programs() {
		// SQL Query
		$sql = "SELECT * FROM api.get_firewall_program_data()";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
		
		// Generate results
        $resultSet = array();
		foreach($query->result_array() as $program) {
			$resultSet[] = new FirewallProgram(
				$program['name'],
				$program['port'],
				$program['transport'],
				$program['date_created'],
				$program['date_modified'],
				$program['last_modifier']
			);
		}
		
		// Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No firewall programs found. This might be an error depending on your configuration. Talk to your administrator.");
		}
	}
	
	public function create_firewall_rule($address, $port, $transport, $deny, $owner, $comment) {
		// SQL Query
		$sql = "SELECT api.create_firewall_rule(
			{$this->db->escape($address)},
			{$this->db->escape($port)},
			{$this->db->escape($transport)},
			{$this->db->escape($deny)},
			{$this->db->escape($owner)},
			{$this->db->escape($comment)}
		)";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
		
		// Generate results
		$rules = $this->get_address_rules($address);
		foreach($rules as $rule) {
			if($rule->get_port() == $port && $rule->get_transport() == $transport) {
				return $rule;
			}
		}
		throw new ObjectNotFoundException("No new rule found. This is a problem. Contact your system administrator");
	}
	
	public function remove_firewall_rule($address, $port, $transport) {
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
}

/* End of file api_firewall.php */
/* Location: ./application/models/API/api_firewall.php */