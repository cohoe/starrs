<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Os extends ImpulseController {

    public function index() {
        $this->_error("What would you like to do today dirtbag?");
    }

    public function view() {
        
    }
}
