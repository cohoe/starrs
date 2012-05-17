<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");
require_once(APPPATH . "models/API/IP/api_ip_create.php");
require_once(APPPATH . "models/API/IP/api_ip_modify.php");
require_once(APPPATH . "models/API/IP/api_ip_remove.php");
require_once(APPPATH . "models/API/IP/api_ip_get.php");
require_once(APPPATH . "models/API/IP/api_ip_list.php");

/**
 * IP address information
 */
class Api_ip extends ImpulseModel {

    /**
     * Constructor
     */
	function __construct() {
		parent::__construct();
		$this->create = new Api_ip_create();
		$this->modify = new Api_ip_modify();
		$this->remove = new Api_ip_remove();
        $this->get    = new Api_ip_get();
		$this->list   = new Api_ip_list();
	}
	
	public function arp($address) {
		// SQL Query
		$sql = "SELECT api.ip_arp({$this->db->escape($address)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		// Return result
		return $query->row()->ip_arp;
	}
	
	public function ip_in_subnet($address, $subnet) {
		// SQL Query
		$sql = "SELECT api.ip_in_subnet({$this->db->escape($address)}, {$this->db->escape($subnet)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		// Return result
		return $query->row()->ip_in_subnet;
	}
	
	public function is_dynamic($address) {
		// SQL Query
		$sql = "SELECT api.ip_is_dynamic({$this->db->escape($address)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		// Return result
		return $query->row()->ip_is_dynamic;
	}
}
/* End of file api_ip.php */
/* Location: ./application/models/API/api_ip.php */