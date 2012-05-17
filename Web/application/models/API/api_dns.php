<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");
require_once(APPPATH . "models/API/DNS/api_dns_create.php");
require_once(APPPATH . "models/API/DNS/api_dns_modify.php");
require_once(APPPATH . "models/API/DNS/api_dns_remove.php");
require_once(APPPATH . "models/API/DNS/api_dns_get.php");
require_once(APPPATH . "models/API/DNS/api_dns_list.php");

/**
 *	DNS
 */
class Api_dns extends ImpulseModel {

    /**
     * Constructor
     */
	public function __construct() {
		parent::__construct();
		$this->create = new Api_dns_create();
		$this->modify = new Api_dns_modify();
		$this->remove = new Api_dns_remove();
        $this->get    = new Api_dns_get();
		$this->list   = new Api_dns_list();
	}

	public function resolve($hostname, $zone, $family) {
		// SQL Query
		$sql = "SELECT api.dns_resolve({$this->db->escape($hostname)},{$this->db->escape($zone)},{$this->db->escape($family)})";
		$query = $this->db->query($sql);
		
		// Check error
		#$this->_check_error($query);
		
		return $query->row()->dns_resolve;
	}

    public function check_hostname($hostname,$zone) {
        // SQL Query
        $sql = "SELECT api.check_dns_hostname({$this->db->escape($hostname)},{$this->db->escape($zone)})";
        $query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

        // Return result
        if($query->row()->check_dns_hostname == 't') {
            return true;
        }
        else {
            return false;
        }
    }
	
	public function nslookup($address) {
		// SQL Query
        $sql = "SELECT api.nslookup({$this->db->escape($address)})";
        $query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);

        // Return result
        if($query->row()->fqdn != "") {
            return $query->row()->fqdn;
        }
        else {
            return null;
        }
	}
}
/* End of file api_dns.php */
/* Location: ./application/models/API/api_dns.php */