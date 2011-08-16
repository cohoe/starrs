<?php  if ( ! defined('BASEPATH')) exit('No direct scrnetworkt access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");
require_once(APPPATH . "models/API/Network/api_network_create.php");
require_once(APPPATH . "models/API/Network/api_network_modify.php");
require_once(APPPATH . "models/API/Network/api_network_remove.php");
require_once(APPPATH . "models/API/Network/api_network_get.php");
require_once(APPPATH . "models/API/Network/api_network_list.php");

/**
 *
 */
class Api_network extends ImpulseModel {

    /**
     *
     */
	function __construct() {
		parent::__construct();
		$this->create = new Api_network_create();
		$this->modify = new Api_network_modify();
		$this->remove = new Api_network_remove();
          $this->get    = new Api_network_get();
		$this->list   = new Api_network_list();
	}

    public function switchview_scan_port_state($systemName) {
        // SQL Query
		$sql = "SELECT api.switchview_scan_port_state({$this->db->escape($systemName)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);
    }
	
	public function switchview_scan_admin_state($systemName) {
        // SQL Query
		$sql = "SELECT api.switchview_scan_admin_state({$this->db->escape($systemName)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);
    }

    public function switchview_scan_mac($systemName) {
        // SQL Query
		$sql = "SELECT api.switchview_scan_mac({$this->db->escape($systemName)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);
    }
	
	public function switchview_scan_description($systemName) {
        // SQL Query
		$sql = "SELECT api.switchview_scan_description({$this->db->escape($systemName)})";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);
    }

}
