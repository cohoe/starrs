<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class DBException extends Exception {

	protected $message;

	public function __construct($message) {
		
		$this->message = $message;
	}
	
	public function permissiondenied() {
		if(preg_match("/permission denied/i", $this->message)) {
			return true;
		}
		else {
			return false;
		}
	}
	
}