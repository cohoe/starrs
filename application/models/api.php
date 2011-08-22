<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");
require_once(APPPATH . "models/API/Management/api_management_create.php");
require_once(APPPATH . "models/API/Management/api_management_modify.php");
require_once(APPPATH . "models/API/Management/api_management_remove.php");
require_once(APPPATH . "models/API/Management/api_management_get.php");

/**
 * The IMPULSE API - the only supported way to interact with the IMPULSE database. 
 */
class Api extends ImpulseModel {

	public $dhcp;
	public $dns;
	public $documentation;
	public $firewall;
	public $ip;
	public $management;
	public $network;
	public $systems;
	public $statistics;

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	/**
	This class does database work. That is all. These functions are the
	only access to the database you get.
	*/
	public function __construct() {
		parent::__construct();
		$this->_load();
		$this->dhcp = new API_DHCP();
		$this->dns = new API_DNS();
		$this->documentation = new API_Documentation();
		$this->firewall = new API_Firewall();
		$this->ip = new API_IP();
		$this->management = new API_Management();
		$this->network = new API_Network();
		$this->systems = new API_Systems();
		$this->statistics = new API_Statistics();
		
		$this->create = new Api_management_create();
		$this->modify = new Api_management_modify();
		$this->remove = new Api_management_remove();
		$this->get = new Api_management_get();
	}

	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS

    /**
     * Return a boolean as to if the current user is an admin or not.
     * @return bool
     */
	public function isadmin() {
		
		if($this->api->get->current_user_level() == "ADMIN") {
			return true;
		}
		else {
			return null;
		}
	}
	
	public function initialize($user) {
		// SQL Query
		$sql = "SELECT api.initialize({$this->db->escape($user)})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
	}
	
	public function deinitialize() {
		// SQL Query
		$sql = "SELECT api.deinitialize()";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
	}

	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS

    /**
     * Load all of the sub models that contain the actual API functions
     * @return void
     */
	private function _load() {
		$this->load->model('API/api_dhcp');
		$this->load->model('API/api_dns');
		$this->load->model('API/api_documentation');
		$this->load->model('API/api_firewall');
		$this->load->model('API/api_ip');
		$this->load->model('API/api_management');
		$this->load->model('API/api_network');
		$this->load->model('API/api_systems');
		$this->load->model('API/api_statistics');

		$this->load->library('impulselib');
	}
}
/* End of file api.php */
/* Location: ./application/models/api.php */