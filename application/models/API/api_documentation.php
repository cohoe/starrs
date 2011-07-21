<?php
require_once(APPPATH . "libraries/core/ImpulseController.php");
/**
 * 
 */
class Api_documentation extends ImpulseController {

    /**
     *
     */
	public function __construct() {
		parent::__construct();
	}
	
	/**
     * @param $schema
     * @return array
     */
    public function get_schema_documentation($schema) {
		if ($schema != "none") {
			$sql = "SELECT * FROM documentation.functions WHERE schema = '$schema' ORDER BY schema,name ASC";
		}
		else {
			$sql = "SELECT * FROM documentation.functions ORDER BY schema,name ASC";
		}
		$query = $this->db->query($sql);
		$this->_check_error($query);
		return $query->result_array();
	}

    /**
     * @param $function
     * @return array
     */
    public function get_function_parameters($function) {
		$sql = "select * from documentation.arguments where specific_name = '$function' order by position asc";
		$query = $this->db->query($sql);
		return $query->result_array();
	}
}
