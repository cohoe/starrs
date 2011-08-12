<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 *	Firewall
 */
class Api_firewall_create extends ImpulseModel {

	public function metahost_member($address,$metahostName) {
		// SQL Query
		$sql = "SELECT * FROM api.create_firewall_metahost_member({$this->db->escape($address)},{$this->db->escape($metahostName)})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

        if($query->num_rows() > 1) {
			throw new APIException("The database returned more than one new record. Contact your system administrator");
		}

		// Return object
		return new MetahostMember(
            $query->row()->name,
            $query->row()->address,
            $query->row()->date_created,
            $query->row()->date_modified,
            $query->row()->last_modifier
        );
	}
	
	public function metahost($name,$owner,$comment) {
		// SQL Query
		$sql = "SELECT * FROM api.create_firewall_metahost(
			{$this->db->escape($name)},
			{$this->db->escape($owner)},
			{$this->db->escape($comment)}
		)";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

		 if($query->num_rows() > 1) {
			throw new APIException("The database returned more than one new record. Contact your system administrator");
		}

		// Return object
		return new Metahost(
            $query->row()->name,
            $query->row()->comment,
            $query->row()->owner,
            $query->row()->date_created,
            $query->row()->date_modified,
            $query->row()->last_modifier
        );
	}
	
	public function metahost_rule($metahostName, $port, $transport, $deny, $comment) {
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
	
	public function standalone_rule($address, $port, $transport, $deny, $owner, $comment) {
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
	
	public function standalone_program($address, $program, $deny, $owner) {
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

    public function metahost_program($metahostName, $programName, $deny) {
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
}
/* End of file api_firewall_create.php */
/* Location: ./application/models/API/DNS/api_firewall_create.php */