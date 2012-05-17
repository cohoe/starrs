<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
/**
 * The replacement IMPULSE controller class. All controllers should extend from this rather than the builtin
 */
abstract class ImpulseModel extends CI_Model {

    public $create;
    public $modify;
    public $remove;
    public $get;
	public $list;

	/**
     * Constructor
     */
	function __construct() {
		parent::__construct();
	}
	
	protected function _check_error($query) {
		if($this->db->_error_number() > 0) {
			throw new DBException($this->db->_error_message());
		}
		if($this->db->_error_message() != "") {
			throw new DBException($this->db->_error_message());
		}
		if($query->num_rows() == 0) {
			throw new ObjectNotFoundException("Object not found!");
		}
	}
}
/* End of file ImpulseModel.php */
/* Location: ./application/libraries/core/ImpulseModel.php */