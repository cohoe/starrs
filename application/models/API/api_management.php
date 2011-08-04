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
}

/* End of file api_management.php */
/* Location: ./application/models/API/api_management.php */