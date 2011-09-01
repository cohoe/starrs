<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *	Management
 */
class Api_systems_create extends ImpulseModel {
	
	public function system($systemName,$owner=NULL,$type,$osName,$comment) {
        // SQL Query
		$sql = "SELECT * FROM api.create_system(
			{$this->db->escape($systemName)},
			{$this->db->escape($owner)},
			{$this->db->escape($type)},
			{$this->db->escape($osName)},
			{$this->db->escape($comment)})";
		$query = $this->db->query($sql);

        // Check errors
		$this->_check_error($query);

        if($query->num_rows() > 1) {
            throw new AmbiguousTargetException("The API returned multiple results?");
        }

		// Generate and return result
        if($query->row()->family ==  'Network') {
            return new NetworkSystem(
                $query->row()->system_name,
                $query->row()->owner,
                $query->row()->comment,
                $query->row()->type,
                $query->row()->family,
                $query->row()->os_name,
                $query->row()->renew_date,
                $query->row()->date_created,
                $query->row()->date_modified,
                $query->row()->last_modifier
            );
        }
        //@todo: Firewall system (also in the database as a system family)
        else {
           return new System(
                $query->row()->system_name,
                $query->row()->owner,
                $query->row()->comment,
                $query->row()->type,
                $query->row()->family,
                $query->row()->os_name,
                $query->row()->renew_date,
                $query->row()->date_created,
                $query->row()->date_modified,
                $query->row()->last_modifier
            );
        }
	}
	
	public function system_quick($systemName, $osName, $mac, $address, $owner) {		
		// SQL Query
		$sql = "SELECT api.create_system_quick(
			{$this->db->escape($systemName)},
			{$this->db->escape($osName)},
			{$this->db->escape($mac)},
			{$this->db->escape($address)},
			{$this->db->escape($owner)})";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
	}
	
	public function _interface($systemName, $mac, $interfaceName, $comment) {
        // SQL Query
		$sql = "SELECT * FROM api.create_interface(
			{$this->db->escape($systemName)},
			{$this->db->escape($mac)},
			{$this->db->escape($interfaceName)},
			{$this->db->escape($comment)})";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);

        if($query->num_rows() > 1) {
            throw new AmbiguousTargetException("The API returned multiple results?");
        }
        
		// Generate and return result
        return new NetworkInterface(
            $query->row()->mac,
            $query->row()->comment,
            $query->row()->system_name,
            $query->row()->name,
            $query->row()->date_created,
            $query->row()->date_modified,
            $query->row()->last_modifier
        );
	}
	
	public function interface_address($mac, $address, $config, $class, $isprimary, $comment) {
	    // SQL Query
		$sql = "SELECT * FROM api.create_interface_address(
			{$this->db->escape($mac)},
			{$this->db->escape($address)},
			{$this->db->escape($config)},
			{$this->db->escape($class)},
			{$this->db->escape($isprimary)},
			{$this->db->escape($comment)}
		)";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);

        if($query->num_rows() > 1) {
            throw new AmbiguousTargetException("The API returned multiple results?");
        }
        
		// Generate and return result
        //$address, $class, $config, $mac, $renewDate, $isPrimary, $comment, $dateCreated, $dateModified, $lastModifier
        return new InterfaceAddress(
            $query->row()->address,
            $query->row()->class,
            $query->row()->config,
            $query->row()->mac,
            $query->row()->renew_date,
            $query->row()->isprimary,
            $query->row()->comment,
            $query->row()->date_created,
            $query->row()->date_modified,
            $query->row()->last_modifier
        );
	}
}
/* End of file api_systems_create.php */
/* Location: ./application/models/API/Systems/api_systems_create.php */
