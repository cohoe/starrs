<?php  if ( ! defined('BASEPATH')) exit('No direct scrnetworkt access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");
require_once(APPPATH . "models/API/Systems/api_systems_create.php");
require_once(APPPATH . "models/API/Systems/api_systems_modify.php");
require_once(APPPATH . "models/API/Systems/api_systems_remove.php");
require_once(APPPATH . "models/API/Systems/api_systems_get.php");
require_once(APPPATH . "models/API/Systems/api_systems_list.php");

class API_Systems extends ImpulseModel {
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

	public function __construct() {
		parent::__construct();
		$this->create = new Api_systems_create();
		$this->modify = new Api_systems_modify();
		$this->remove = new Api_systems_remove();
        $this->get    = new Api_systems_get();
		$this->list   = new Api_systems_list();
	}

	public function renew($systemName) {
		// SQL Query
		$sql = "SELECT api.renew_system({$this->db->escape($systemName)})";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
	}
}
/* End of file api_systems.php */
/* Location: ./application/models/API/api_systems.php */