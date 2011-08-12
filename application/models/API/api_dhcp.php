<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");
require_once(APPPATH . "models/API/DHCP/api_dhcp_create.php");
require_once(APPPATH . "models/API/DHCP/api_dhcp_modify.php");
require_once(APPPATH . "models/API/DHCP/api_dhcp_remove.php");
require_once(APPPATH . "models/API/DHCP/api_dhcp_get.php");
require_once(APPPATH . "models/API/DHCP/api_dhcp_list.php");

/**
 * DHCP
 */
class Api_dhcp extends ImpulseModel {

    /**
     * Constructor
     */
	public function __construct() {
		parent::__construct();
		$this->create = new Api_dhcp_create();
		$this->modify = new Api_dhcp_modify();
		$this->remove = new Api_dhcp_remove();
        $this->get    = new Api_dhcp_get();
		$this->list   = new Api_dhcp_list();
	}
	
	
	public function reload() {
		// SQL Query
		$sql = "SELECT api.generate_dhcpd_config()";
		$query = $this->db->query($sql);

		// Check error
		$this->_check_error($query);
	}
}

/* End of file api_dhcp.php */
/* Location: ./application/models/API/api_dhcp.php */