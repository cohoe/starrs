<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/**
 * An exception thrown from the IMPULSE core.
 */
class DBException extends Exception {

    ////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES

    ////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR

    /**
     * @param $message  The message from the error source
     */
	public function __construct($message) {

        // Parse the error message for only the ERROR portion, not CONTEXT as well
		// I hate PHP regex. It wouldn't let me do (.*?)
		#$message = preg_replace('/^ERROR: ([^&]*)CONTEXT([^&]*)$/i', '\1', $message);
		$this->message = $message;
	}

    ////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
}

/* End of file DBException.php */
/* Location: ./application/libraries/exceptions/DBException.php */