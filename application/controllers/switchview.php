<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Switchview extends ImpulseController {

    public function view($systemName=NULL) {
        $systemName = rawurldecode($systemName);
        try {
            $this->_load_system($systemName);
        }
        catch(ObjectNotFoundException $onfE) {
            $this->_error("Unable to find system \"$systemName\"");
        }

        $settings = $this->api->network->get->switchview_settings($systemName);
        print_r($settings);
    }

}
/* End of file switchview.php */
/* Location: ./application/controllers/switchview.php */