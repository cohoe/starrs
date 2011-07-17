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
		
		// I hate PHP regex. It wouldnt let me do (.*?) 
		$message = preg_replace('/^ERROR: ([^&]*)CONTEXT([^&]*)$/i', '\1', $message);
		$this->message = $message;
	}

    /**
     * @return bool
     */
	public function permissiondenied() {
		if(preg_match("/permission/i", $this->message)) {
			return true;
		}
		else {
			return false;
		}
	}
}
