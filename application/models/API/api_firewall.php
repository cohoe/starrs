<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseModel.php");
require_once(APPPATH . "models/API/Firewall/api_firewall_create.php");
require_once(APPPATH . "models/API/Firewall/api_firewall_modify.php");
require_once(APPPATH . "models/API/Firewall/api_firewall_remove.php");
require_once(APPPATH . "models/API/Firewall/api_firewall_get.php");
require_once(APPPATH . "models/API/Firewall/api_firewall_list.php");

/**
 * Firewall related information
 */
class Api_firewall extends ImpulseModel {

    /**
     * Constructor
     */
	public function __construct() {
		parent::__construct();
		$this->create = new Api_firewall_create();
		$this->modify = new Api_firewall_modify();
		$this->remove = new Api_firewall_remove();
        $this->get    = new Api_firewall_get();
		$this->list   = new Api_firewall_list();
	}
	

}
/* End of file api_firewall.php */
/* Location: ./application/models/API/api_firewall.php */