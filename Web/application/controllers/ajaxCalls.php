<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

/**
 * This controller takes care of all ajax-y calls. All requests are GET
 * requests and return JSON formatted 
 */
class AjaxCalls extends ImpulseController {
	
	public function index() {
		die(json_encode(array("error"=>"This script cannot be accessed directly!")));
	}
	
	public function getHelp() {
		die(json_encode(array("error"=>"We don't have any help yet.")));
	}
	
	/**
	 * This method will return a nice JSON object that tells the user if the
	 * hostname provided in the POST request is in use or not. It can also be
	 * fleshed out with verification tools like invalid characters and such.
	 */
	public function hostnameInUse() {
		// Verify that we have a hostname and zone to verify
		if(!$this->input->post('hostname') || !$this->input->post('zone')) {
			die(json_encode(array("error" => "You must provide a hostname to verify!")));
		}
		$hostname = $this->input->post('hostname');
		$zone     = $this->input->post('zone');
		
		// Now we need to get a copy of the API and attempt to get the hostname
		$inUse = $this->api->dns->check_hostname($hostname, $zone);
		
		echo json_encode(array("inUse"=>$inUse));
	}
}
