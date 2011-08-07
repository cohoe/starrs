<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Switchview extends ImpulseController {

    public function settings($systemName=NULL) {
        $systemName = rawurldecode($systemName);
        try {
            $this->_load_system($systemName);
        }
        catch(ObjectNotFoundException $onfE) {
            $this->_error("Unable to find system \"$systemName\"");
        }

        $settings = $this->api->network->get->switchview_settings($systemName);

        // Navbar
        $navModes['EDIT'] = "/switchview/edit/".rawurlencode(self::$sys->get_system_name());
        $navOptions['System'] = "/systems/view/".rawurlencode(self::$sys->get_system_name());
        $navbar = new Navbar("Switchview Settings - ".self::$sys->get_system_name(), $navModes, $navOptions);

        // Load view data
        $info['header'] = $this->load->view('core/header',"",TRUE);
        $info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
        $info['title'] = "Switchview Settings - ".self::$sys->get_system_name();
        $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
        $info['data'] = $this->load->view('network/switchview/view',array("settings"=>$settings),TRUE);

        // Load the main view
        $this->load->view('core/main',$info);
    }

}
/* End of file switchview.php */
/* Location: ./application/controllers/switchview.php */