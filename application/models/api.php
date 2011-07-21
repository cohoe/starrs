<?php

/**
 * The IMPULSE API - the only supported way to interact with the IMPULSE database. 
 */
class Api extends CI_Model {

	public $dhcp;
	public $dns;
	public $documentation;
	public $firewall;
	public $ip;
	public $management;
	public $network;
	public $systems;

    private $fname;
	private $lname;
	private $uname;

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

        $this->uname = $this->input->server('WEBAUTH_USER');
		$this->fname = $this->input->server('WEBAUTH_LDAP_GIVENNAME');
		$this->lname = $this->input->server('WEBAUTH_LDAP_SN');
		#$this->uname = "sean";
		#$this->fname = "Grant";
		#$this->lname = "Cohoe";
	}

	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS

    /**
     * Return a boolean as to if the current user is an admin or not.
     * @return bool
     */
	public function isadmin() {
		
		if($this->api->management->get_current_user_level() == "ADMIN") {
			return true;
		}
		else {
			return false;
		}
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

		$this->load->library('impulselib');
	}

    /**
     * Get your username
     * @return string
     */
	public function get_username() {
		return $this->uname;
	}

    /**
     * Get your real name
     * @return string
     */
	public function get_name() {
		return "$this->fname $this->lname";
	}
}
