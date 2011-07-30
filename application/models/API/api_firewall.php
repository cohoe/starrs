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
            switch($fwRule['source']) {
                case "standalone-standalone":
                    $resultSet[] = new StandaloneRule(
                        $fwRule['address'],
                        $fwRule['port'],
                        $fwRule['transport'],
                        $fwRule['deny'],
                        $fwRule['comment'],
                        $fwRule['owner'],
                        $fwRule['date_created'],
                        $fwRule['date_modified'],
                        $fwRule['last_modifier']
                    );
                    break;
                case "standalone-program":
                    $resultSet[] = new StandaloneProgram(
                        $fwRule['address'],
                        $this->get_firewall_program($fwRule['port']),
                        $fwRule['port'],
                        $fwRule['transport'],
                        $fwRule['deny'],
                        $fwRule['comment'],
                        $fwRule['owner'],
                        $fwRule['date_created'],
                        $fwRule['date_modified'],
                        $fwRule['last_modifier']
                    );
                    break;
                case "metahost-standalone":
                    $resultSet[] = new MetahostRule(
                        $this->get_metahost_member($fwRule['address'])->get_name(),
                        $fwRule['port'],
                        $fwRule['transport'],
                        $fwRule['deny'],
                        $fwRule['comment'],
                        $fwRule['owner'],
                        $fwRule['date_created'],
                        $fwRule['date_modified'],
                        $fwRule['last_modifier']
                    );
                    break;
                case "metahost-program":
                    $resultSet[] = new MetahostProgram(
                        $this->get_metahost_member($fwRule['address'])->get_name(),
                        $this->get_firewall_program($fwRule['port']),
                        $fwRule['port'],
                        $fwRule['transport'],
                        $fwRule['deny'],
                        $fwRule['comment'],
                        $fwRule['owner'],
                        $fwRule['date_created'],
                        $fwRule['date_modified'],
                        $fwRule['last_modifier']
                    );
                    break;
                default:
                    throw new DBException("Invalid rule source found. This is a DB problem. Contact your system administrator.");
            }

        }

//        $resultSet[] = new FirewallRule(
//                $fwRule['port'],
//                $fwRule['transport'],
//                $fwRule['deny'],
//                $fwRule['comment'],
//                $fwRule['address'],
//                $fwRule['owner'],
//                $fwRule['source'],
//                $fwRule['date_created'],
//                $fwRule['date_modified'],
//                $fwRule['last_modifier']
//            );

        // Return results
        if(count($resultSet > 0)) {
            return $resultSet;
        }
        else {
			throw new ObjectNotFoundException("No firewall rules found.");
		}
	}

	// @todo: Need a function that will give all the rules that eventually apply to an address
	public function load_address_rules($address) {
		$resultSet = array();

		try {
			$stdRules = $this->get_standalone_rules($address);
			foreach($stdRules as $rule) {
				$resultSet[] = $rule;
			}
		}
		catch (ObjectNotFoundException $onfE) {}
		try {
			$stdProgs = $this->get_standalone_program_rules($address);
			foreach($stdProgs as $rule) {
				$resultSet[] = $rule;
			}
		}
		catch (ObjectNotFoundException $onfE) {}
		return $resultSet;
	}
	
	public function create_standalone_rule($address, $port, $transport, $deny, $owner, $comment) {
		// SQL Query
		$sql = "SELECT * FROM api.create_firewall_rule(
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

        if($query->num_rows() > 1) {
            throw new AmbiguousTargetException("The API returned more than one object. This is a problem. Contact your system administrator");
        }
		
		// Generate results
        return new StandaloneRule(
            $query->row()->address,
            $query->row()->port,
            $query->row()->transport,
            $query->row()->deny,
            $query->row()->comment,
            $query->row()->owner,
            $query->row()->date_created,
            $query->row()->date_modified,
            $query->row()->last_modifier
        );
	}
	
	public function create_standalone_program($address, $program, $deny, $owner) {
		// SQL Query
		$sql = "SELECT * FROM api.create_firewall_rule_program(
			{$this->db->escape($address)},
			{$this->db->escape($program)},
			{$this->db->escape($deny)},
			{$this->db->escape($owner)}
		)";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

        if($query->num_rows() > 1) {
            throw new AmbiguousTargetException("The API returned more than one object. This is a problem. Contact your system administrator");
        }
		
		// Generate results
		return new StandaloneProgram(
            $query->row()->address,
            $query->row()->name,
            $query->row()->port,
            $query->row()->transport,
            $query->row()->deny,
            $query->row()->comment,
            $query->row()->owner,
            $query->row()->date_created,
            $query->row()->date_modified,
            $query->row()->last_modifier
        );
	}

    public function create_metahost_rule($metahostName, $port, $transport, $deny, $comment) {
        // SQL Query
        $sql = "SELECT * FROM api.create_firewall_metahost_rule(
            {$this->db->escape($metahostName)},
            {$this->db->escape($port)},
            {$this->db->escape($transport)},
            {$this->db->escape($deny)},
            {$this->db->escape($comment)}
        )";

        $query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

        if($query->num_rows() > 1) {
            throw new AmbiguousTargetException("The API returned more than one object. This is a problem. Contact your system administrator");
        }

        // Generate and return results
        return new MetahostRule(
            $query->row()->name,
            $query->row()->port,
            $query->row()->transport,
            $query->row()->deny,
            $query->row()->comment,
            $query->row()->owner,
            $query->row()->date_created,
            $query->row()->date_modified,
            $query->row()->last_modifier
        );
    }

    public function create_metahost_program($metahostName, $programName, $deny) {
        // SQL Query
        $sql = "SELECT * FROM api.create_firewall_metahost_rule_program(
            {$this->db->escape($metahostName)},
            {$this->db->escape($programName)},
            {$this->db->escape($deny)}
        )";

        $query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

        if($query->num_rows() > 1) {
            throw new AmbiguousTargetException("The API returned more than one object. This is a problem. Contact your system administrator");
        }
        
        // Generate and return results
        return new MetahostProgram(
            $query->row()->metahost_name,
            $query->row()->program_name,
            $query->row()->port,
            $query->row()->transport,
            $query->row()->deny,
            $query->row()->comment,
            $query->row()->owner,
            $query->row()->date_created,
            $query->row()->date_modified,
            $query->row()->last_modifier
        );
    }

    public function create_metahost_member($address,$metahostName) {
		// SQL Query
		$sql = "SELECT * FROM api.create_firewall_metahost_member({$this->db->escape($address)},{$this->db->escape($metahostName)})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

		// Return result object
		return $this->get_metahost_member($address);
	}

    public function create_metahost($name,$owner,$comment) {
		// SQL Query
		$sql = "SELECT api.create_firewall_metahost(
			{$this->db->escape($name)},
			{$this->db->escape($owner)},
			{$this->db->escape($comment)}
		)";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

		return $this->get_metahost($name);
	}
	
	public function remove_standalone_rule($address, $port, $transport) {
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
	
	public function remove_standalone_program($address, $program) {
		// SQL Query
		$sql = "SELECT api.remove_firewall_rule_program(
			{$this->db->escape($address)},
			{$this->db->escape($program)}
		)";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
	}

    public function remove_metahost_rule($metahostName, $port, $transport) {
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
	
	public function remove_metahost($mHost) {
		// SQL Query
		$sql = "SELECT api.remove_firewall_metahost({$this->db->escape($mHost->get_name())})";
		$query = $this->db->query($sql);

		
        // Check error
        $this->_check_error($query);
	}

	public function remove_metahost_member($membr) {
		// SQL Query
		$sql = "SELECT api.remove_firewall_metahost_member({$this->db->escape($membr->get_address())})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
	}

    public function modify_metahost($metahostName, $field, $newValue) {
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
    
    public function get_metahost_members($metahostName) {
		// SQL Query
		$sql = "SELECT * FROM api.get_firewall_metahost_members({$this->db->escape($metahostName)})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

		// Generate results
		$resultSet = array();
		foreach($query->result_array() as $result) {
			$resultSet[] = new MetahostMember(
				$result['name'],
				$result['address'],
				$result['date_created'],
				$result['date_modified'],
				$result['last_modifier']
			);
		}

		// Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No firewall metahost members found.");
		}
	}
	
	public function get_metahosts($username=NULL) {
		// SQL Query
		$sql = "SELECT * FROM api.get_firewall_metahosts({$this->db->escape($username)})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

		// Generate results
        $resultSet = array();
		foreach($query->result_array() as $metahost) {
			$resultSet[] = new Metahost(
				$metahost['name'],
				$metahost['comment'],
				$metahost['owner'],
				$metahost['date_created'],
				$metahost['date_modified'],
				$metahost['last_modifier']
			);
		}

		// Return results
		if(count($resultSet) > 0) {
			return $resultSet;
		}
		else {
			throw new ObjectNotFoundException("No firewall metahosts found.");
		}
	}

	public function get_metahost($metahostName,$complete=FALSE) {
		// SQL Query
		$sql = "SELECT * FROM api.get_firewall_metahost({$this->db->escape($metahostName)})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

		if($query->num_rows() > 1) {
			throw new AmbiguousTargetException("Multiple metahosts found. This indicates a database error. Talk to your system administrator");
		}

		// Generate result
		$mHost =  new Metahost(
			$query->row()->name,
			$query->row()->comment,
			$query->row()->owner,
			$query->row()->date_created,
			$query->row()->date_modified,
			$query->row()->last_modifier
		);

		if($complete == TRUE) {
			try {
				$members = $this->get_metahost_members($metahostName);
				foreach($members as $membr) {
					$mHost->add_member($membr);
				}
			}
			catch(ObjectNotFoundException $onfE) { }
		}

		// Return result
		return $mHost;
	}
	
	public function get_metahost_member($address) {
		// SQL Query
		$sql = "SELECT * FROM api.get_firewall_metahost_member({$this->db->escape($address)})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
		
		if($query->num_rows() > 1) {
			throw new AmbiguousTargetException("Multiple metahosts found. This indicates a database error. Talk to your system administrator");
		}
		
		// Generate result
		$membr =  new MetahostMember(
			$query->row()->name,
			$query->row()->address,
			$query->row()->date_created,
			$query->row()->date_modified,
			$query->row()->last_modifier
		);
		
		return $membr;
	}

	public function get_standalone_rules($address) {
		// SQL Query
		$sql = "SELECT * FROM api.get_firewall_standalone_rules({$this->db->escape($address)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		// Generate result
		$resultSet = array();
		foreach($query->result_array() as $rule) {
			$resultSet[] = new StandaloneRule(
				$rule['address'],
				$rule['port'],
				$rule['transport'],
				$rule['deny'],
				$rule['comment'],
				$rule['owner'],
				$rule['date_created'],
				$rule['date_modified'],
				$rule['last_modifier']
			);
		}

		// Return results
		return $resultSet;
	}

	public function get_standalone_program_rules($address) {
		// SQL Query
		$sql = "SELECT * FROM api.get_firewall_standalone_program_rules({$this->db->escape($address)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

		// Generate result
		$resultSet = array();
		foreach($query->result_array() as $rule) {
			$resultSet[] = new StandaloneProgram(
				$rule['address'],
				$rule['name'],
				$rule['port'],
				$rule['transport'],
				$rule['deny'],
				$rule['comment'],
				$rule['owner'],
				$rule['date_created'],
				$rule['date_modified'],
				$rule['last_modifier']
			);
		}

		// Return results
		return $resultSet;
	}

    public function get_metahost_rules($metahostName) {
		// SQL Query
		$sql = "SELECT * FROM api.get_firewall_metahost_rules({$this->db->escape($metahostName)})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

		// Generate results
        $resultSet = array();
        foreach($query->result_array() as $fwRule) {
            $resultSet[] = new MetahostRule(
				$fwRule['name'],
				$fwRule['port'],
				$fwRule['transport'],
				$fwRule['deny'],
				$fwRule['comment'],
				$fwRule['owner'],
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
			throw new ObjectNotFoundException("No standalone metahost rules found.");
		}
	}

	public function get_metahost_program_rules($metahostName) {
		// SQL Query
		$sql = "SELECT * FROM api.get_firewall_metahost_program_rules({$this->db->escape($metahostName)})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

		// Generate results
        $resultSet = array();
        foreach($query->result_array() as $fwRule) {
            $resultSet[] = new MetahostProgram(
				$fwRule['metahost_name'],
				$fwRule['program_name'],
				$fwRule['port'],
				$fwRule['transport'],
				$fwRule['deny'],
				$fwRule['comment'],
				$fwRule['owner'],
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
			throw new ObjectNotFoundException("No program metahost rules found.");
		}
	}

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
}
/* End of file api_firewall.php */
/* Location: ./application/models/API/api_firewall.php */