<?php  if ( ! defined('BASEPATH')) exit('No direct scrnetworkt access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");
require_once(APPPATH . "models/API/Network/api_network_create.php");
require_once(APPPATH . "models/API/Network/api_network_modify.php");
require_once(APPPATH . "models/API/Network/api_network_remove.php");
require_once(APPPATH . "models/API/Network/api_network_get.php");

/**
 *
 */
class Api_network extends ImpulseModel {

    /**
     *
     */
	function __construct() {
		parent::__construct();
		$this->create = new Api_network_create();
		$this->modify = new Api_network_modify();
		$this->remove = new Api_network_remove();
        $this->get    = new Api_network_get();
	}
}