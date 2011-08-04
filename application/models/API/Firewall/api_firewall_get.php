<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 *	Firewall
 */
class Api_firewall_get extends ImpulseModel {

	public function _default($address) {
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

	public function program($port) {
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

	public function address_rules($address) {
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
                        $this->program($fwRule['port']),
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
                        $this->metahost_member($fwRule['address'])->get_name(),
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
                        $this->metahost_member($fwRule['address'])->get_name(),
                        $this->program($fwRule['port']),
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

        // Return results
        if(count($resultSet > 0)) {
            return $resultSet;
        }
        else {
			throw new ObjectNotFoundException("No firewall rules found.");
		}
	}

	public function transports() {
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
	
	public function programs() {
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
	
	public function metahosts($username=NULL) {
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
	
	public function metahost($metahostName,$complete=FALSE) {
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
				$members = $this->metahost_members($metahostName);
				foreach($members as $membr) {
					$mHost->add_member($membr);
				}
			}
			catch(ObjectNotFoundException $onfE) { }
			
			try {
				$fwRules = $this->metahost_program_rules($metahostName);
				foreach($fwRules as $rule) {
					$mHost->add_rule($rule);
				}
			}
			catch(ObjectNotFoundException $onfE) { }
			
			try {
				$fwRules = $this->metahost_rules($metahostName);
				foreach($fwRules as $rule) {
					$mHost->add_rule($rule);
				}
			}
			catch(ObjectNotFoundException $onfE) { }
		}

		// Return result
		return $mHost;
	}
	
	public function metahost_members($metahostName) {
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
	
	public function metahost_member($address) {
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

	public function standalone_rules($address) {
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

	public function standalone_program_rules($address) {
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

    public function metahost_rules($metahostName) {
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

	public function metahost_program_rules($metahostName) {
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
	
	public function addresses($subnet) {
		// SQL Query
		$sql = "SELECT * FROM api.get_firewall_addresses({$this->db->escape($subnet)})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
		
		// Generate results
		$resultSet = array();
		foreach($query->result_array() as $result) {
			if($result['isprimary'] == 't') {
				$resultSet['primary'] = $result['address'];
			}
			else {
				$resultSet['secondary'] = $result['address'];
			}
		}
		
		// Return results
		return $resultSet;
	}

	// @todo: Default data
	
	// @todo: Rule database
	
	// @todo: Rule queue
	
	// @todo: Default queue
}
/* End of file api_firewall_get.php */
/* Location: ./application/models/API/DNS/api_firewall_get.php */