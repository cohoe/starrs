<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");

/**
 *	DHCP Create
 */
class Api_dhcp_create extends ImpulseModel {
	
	public function _class($name, $comment) {
		// SQL Query
		$sql = "SELECT * FROM api.create_dhcp_class(
			{$this->db->escape($name)},
			{$this->db->escape($comment)}
		)";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		if($query->num_rows() > 1) {
			throw new APIException("The database returned more than one class. Contact your system administrator");
		}
		
		// Return object
		return new DhcpClass(
			$query->row()->class,
			$query->row()->comment,
			$query->row()->date_created,
			$query->row()->date_modified,
			$query->row()->last_modifier
		);
	}
	
	public function class_option($class, $option, $value) {
		// SQL Query
		$sql = "SELECT * FROM api.create_dhcp_class_option(
			{$this->db->escape($class)},
			{$this->db->escape($option)},
			{$this->db->escape($value)}
		)";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		if($query->num_rows() > 1) {
			throw new APIException("The database returned more than one class option. Contact your system administrator");
		}
		
		// Return object
		return new ClassOption(
			$class,
			$query->row()->option,
			$query->row()->value,
			$query->row()->date_created,
			$query->row()->date_modified,
			$query->row()->last_modifier
		);
	}
	
	public function subnet_option($subnet, $option, $value) {
		// SQL Query
		$sql = "SELECT * FROM api.create_dhcp_subnet_option(
			{$this->db->escape($subnet)},
			{$this->db->escape($option)},
			{$this->db->escape($value)}
		)";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		if($query->num_rows() > 1) {
			throw new APIException("The database returned more than one subnet option. Contact your system administrator");
		}
		
		// Return object
		return new SubnetOption(
			$subnet,
			$query->row()->option,
			$query->row()->value,
			$query->row()->date_created,
			$query->row()->date_modified,
			$query->row()->last_modifier
		);
	}
	
	public function range_option($range, $option, $value) {
		// SQL Query
		$sql = "SELECT * FROM api.create_dhcp_range_option(
			{$this->db->escape($range)},
			{$this->db->escape($option)},
			{$this->db->escape($value)}
		)";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		if($query->num_rows() > 1) {
			throw new APIException("The database returned more than one range option. Contact your system administrator");
		}
		
		// Return object
		return new RangeOption(
			$range,
			$query->row()->option,
			$query->row()->value,
			$query->row()->date_created,
			$query->row()->date_modified,
			$query->row()->last_modifier
		);
	}
	
	public function global_option($option, $value) {
		// SQL Query
		$sql = "SELECT * FROM api.create_dhcp_global_option(
			{$this->db->escape($option)},
			{$this->db->escape($value)}
		)";
		$query = $this->db->query($sql);
		
		// Check error
		$this->_check_error($query);
		
		if($query->num_rows() > 1) {
			throw new APIException("The database returned more than one global option. Contact your system administrator");
		}
		
		// Return object
		return new GlobalOption(
			$query->row()->option,
			$query->row()->value,
			$query->row()->date_created,
			$query->row()->date_modified,
			$query->row()->last_modifier
		);
	}
}
/* End of file api_dhcp_create.php */
/* Location: ./application/models/API/DHCP/api_dhcp_create.php */
