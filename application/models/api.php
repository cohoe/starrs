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

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	/* Constructor
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
		
		$this->management->initialize($this->impulselib->get_username());
	}

	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
	
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
	
	private function _load() {
		$this->load->model('API/API_DHCP');
		$this->load->model('API/API_DNS');
		$this->load->model('API/API_Documentation');
		$this->load->model('API/API_Firewall');
		$this->load->model('API/API_IP');
		$this->load->model('API/API_Management');
		$this->load->model('API/API_Network');
		$this->load->model('API/API_Systems');
	}
}
