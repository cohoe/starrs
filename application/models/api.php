<?php
class Api extends CI_Model {

	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	/* Constructor
	This class does database work. That is all. These functions are the
	only access to the database you get.
	*/
	function __construct()
	{
		parent::__construct();
	}
	
	////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
	
	/**
	 * Initiaizes the API for usage with the given user.
	 * @param 	string 	$user	The username to initialze the db with
	 */
	public function intialize($user)
	{
		// Escape it!
		$user = $this->db->escape($user);
		
		// Run it!
		$sql = "SELECT api.initialize({$user})";
		$query = $this->db->query($sql);
		
		return $query;
	}
	
	public function deinitialize()
	{
		$sql = "SELECT api.deinitialize()";
		$query = $this->db->query($sql);
		return $query;
	}
	
	public function get_system_info($system_name)
	{
		$sql = "SELECT * FROM systems.systems WHERE system_name = '$system_name'";
		$query = $this->db->query($sql);
		if ($query->num_rows() == 1)
		{
			return $query->row_array();
		}
		else
		{
			echo "Multiple systems found?";
			die;
		}
	}
	
	public function get_system_interfaces($system_name)
	{
		$sql = "SELECT * from systems.interfaces WHERE system_name = '$system_name' ORDER BY mac ASC";
		$query = $this->db->query($sql);
		return $query->result_array();
	}
	
	public function get_interface_addresses($mac)
	{
		# This is DESC for temporary viewing purposes. It will be made ASC later
		$sql = "SELECT * from systems.interface_addresses WHERE mac = '$mac' ORDER BY name DESC";
		$query = $this->db->query($sql);
		return $query->result_array();
	}
	
	public function get_address_rules($address)
	{
		$sql = "SELECT * from firewall.rules WHERE address = '$address' ORDER BY port ASC";
		$query = $this->db->query($sql);
		return $query->result_array();
	}

	public function get_schema_documentation($schema)
	{
		if ($schema != "none")
		{
			$sql = "SELECT * FROM documentation.functions WHERE schema = '$schema' ORDER BY schema,name ASC";
		}
		else
		{
			$sql = "SELECT * FROM documentation.functions ORDER BY schema,name ASC";
		}
		$query = $this->db->query($sql);
		return $query->result_array();
	}

	public function get_function_parameters($function)
	{
		$sql = "select * from documentation.arguments where specific_name = '$function' order by position asc";
		$query = $this->db->query($sql);
		return $query->result_array();
	}
	
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
}
