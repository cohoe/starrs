<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 * Management access to the general site configuration.
 * @throws DBException
 */
class Api_management extends ImpulseModel {

    /**
     * Constructor
     */
	public function __construct() {
		parent::__construct();
	}

    /**
     * Get the current database permission level
     * @return string
     */
	public function get_current_user_level() {
        // SQL Query
		$sql = "SELECT api.get_current_user_level()";
		$query = $this->db->query($sql);

        // Check errors
        $this->_check_error($query);

        // Return result
		return $query->row()->get_current_user_level;
	}
	
	/**
	 * Initializes the API for usage with the given user.
	 * @param 	string 	$user	The username to initialize the db with
	 * @return	bool			True on success
	 * 							False on recoverable error
	 */
	public function initialize($user) {
		// SQL Query
		$sql = "SELECT api.initialize({$this->db->escape($user)})";
		$query = $this->db->query($sql);

        // Check error
        $this->_check_error($query);
	}
	
	/**
	 * Deinitializes the API for usage with the already provided user.
	 * @return	bool			True on success
	 * 							False on recoverable failure
	 */
	public function deinitialize() {
		// SQL Query
		$sql = "SELECT api.deinitialize()";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
	}
	
	public function get_site_configuration($directive) {
		// SQL Query
		$sql = "SELECT api.get_site_configuration({$this->db->escape($directive)})";
		$query = $this->db->query($sql);
		
		// Check error
        $this->_check_error($query);
		
		// Return result
		return $query->row()->get_site_configuration;
	}
}

/* End of file api_management.php */
/* Location: ./application/models/API/api_management.php */