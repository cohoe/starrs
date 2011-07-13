<?php
/**
 * @throws DBException
 *
 */
class Api_management extends CI_Model {

    /**
     *
     */
	public function __construct() {
		parent::__construct();
	}

    /**
     * @return
     */
	public function get_current_user_level() {
		$sql = "SELECT api.get_current_user_level()";
		$query = $this->db->query($sql);
		return $query->row()->get_current_user_level;
	}
	
	/**
	 * Initiaizes the API for usage with the given user.
	 * @param 	string 	$user	The username to initialze the db with
	 * @return	bool			True on success
	 * 							False on recoverable error
	 */
	public function initialize($user) {
		
		// Run it!
		$sql = "SELECT api.initialize({$this->db->escape($user)})";
		$query = $this->db->query($sql);
		
		return $query;
	}
	
	/**
	 * Deinitializes the API for usage with the already provided user.
	 * @return	bool			True on success
	 * 							False on recoverable failure
	 */
	public function deinitialize() {
		// Run the query
		$sql = "SELECT api.deinitialize()";
		$query = $this->db->query($sql);
		
		if($this->db->_error_number() > 0) {
			throw new DBException("A database error occurred: " . $this->db->_error_message());
		}
		
		return true;
	}
}