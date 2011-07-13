<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 *
 */
class DBException extends Exception {

	protected $message;

    /**
     * @param $message
     */
	public function __construct($message) {
		
		$this->message = $message;
	}

    /**
     * @return bool
     */
	public function permissiondenied() {
		if(preg_match("/permission denied/i", $this->message)) {
			return true;
		}
		else {
			return false;
		}
	}
	
}