<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Switchport extends ImpulseController {

    public static $sPort;

    public function view($systemName=NULL,$portName=NULL) {
        if($systemName==NULL) {
            $this->_error("No system name specified for port view");
        }
        if($portName==NULL) {
            $this->_error("No port name specified view");
        }

        $this->_load_system(urldecode($systemName));
        $this->_load_switchports(urldecode($systemName));
        $sPort = self::$sys->get_switchport(rawurldecode($portName));

        // Navbar
        #$navModes['EDIT'] = "/switchport/edit/".rawurlencode(self::$sys->get_system_name())."/".rawurlencode($portName);
        $navOptions['Switchports'] = "/switchports/view/".rawurlencode(self::$sys->get_system_name());
        $navbar = new Navbar("Switchport Details", null, $navOptions);

        // Load view data
        $info['header'] = $this->load->view('core/header',"",TRUE);
        $info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
        $info['title'] = "Switchport Details";
        $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
        $info['data'] = $this->load->view('switchport/view',array("sPort"=>$sPort),TRUE);

        // Load the main view
        $this->load->view('core/main',$info);
    }
}
/* End of file switchport.php */
/* Location: ./application/controllers/switchport.php */