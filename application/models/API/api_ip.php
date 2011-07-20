<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 * IP address information
 */
class Api_ip extends ImpulseModel {

    /**
     * Constructor
     */
	function __construct() {
		parent::__construct();
	}

    /**
     * @return array<IpRange>
     */
	public function get_ranges() {
        // SQL Query
		$sql = "SELECT * FROM api.get_ip_ranges()";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);

        // Generate results
        $resultSet = array();
        foreach($query->result_array() as $range) {
            $resultSet[] = new IpRange(
                $range['first_ip'],
                $range['last_ip'],
                $range['use'],
                $range['name'],
                $range['subnet'],
                $range['class'],
                $range['comment'],
                $range['date_created'],
                $range['date_modified'],
                $range['last_modifier']
            );
        }

        // Return results
        if(count($resultSet) > 0) {
            return $resultSet;
        }
        else {
            throw new ObjectNotFoundException("No ranges were found. This indicates a database error. Contact your system administrator");
        }
	}

    /**
     * Get the first available address from an IP range
     * @param $range        The name of the range to pull from
     * @return string       The IP address for you to use
     */
	public function get_address_from_range($range) {
        // SQL query
		$sql = "SELECT api.get_address_from_range({$this->db->escape($range)})";
		$query = $this->db->query($sql);

        // Check errors
        $this->_check_error($query);
        
        // Generate and return result
		return $query->row()->get_address_from_range;
	}

    /**
     * Get the name of the range that an address is contained within
     * @param $address      The address to search on
     * @return              The name of the range
     */
	public function get_address_range($address) {
        // SQL Query
		$sql = "SELECT api.get_address_range({$this->db->escape($address)})";
		$query = $this->db->query($sql);

        // Check errors
        $this->_check_error($query);

        // Generate and return result
		return $query->row()->get_address_range;
	}
}

/* End of file api_ip.php */
/* Location: ./application/models/API/api_ip.php */