<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");
require_once(APPPATH . "models/API/Statistics/api_statistics_get.php");

class API_Statistics extends ImpulseModel {
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

	public function __construct() {
		parent::__construct();
        $this->get    = new Api_statistics_get();
	}
}
/* End of file api_statistics.php */
/* Location: ./application/models/API/api_statistics.php */