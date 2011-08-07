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
        $navModes['EDIT'] = "/switchport/edit/".rawurlencode(self::$sys->get_system_name())."/".rawurlencode($portName);
        $navModes['DELETE'] = "/switchport/delete/".rawurlencode(self::$sys->get_system_name())."/".rawurlencode($sPort->get_port_name());
        $navOptions['Switchports'] = "/switchports/view/".rawurlencode(self::$sys->get_system_name());
        $navbar = new Navbar("Switchport Details", $navModes, $navOptions);

        // Load view data
        $info['header'] = $this->load->view('core/header',"",TRUE);
        $info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
        $info['title'] = "Switchport Details";
        $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
        $viewData['sPort'] = $sPort;
        $viewData['sys'] = self::$sys;
        $info['data'] = $this->load->view('switchport/view',$viewData,TRUE);

        // Load the main view
        $this->load->view('core/main',$info);
    }

    public function delete($systemName=NULL,$portName=NULL) {
        if($systemName==NULL) {
            $this->_error("No system name specified for port delete");
        }
        if($portName==NULL) {
            $this->_error("No port name specified delete");
        }

        $systemName = rawurldecode($systemName);
        $portName = rawurldecode($portName);

        try {
            $this->api->network->remove->switchport($portName, $systemName);
            redirect(base_url()."switchports/view/".rawurlencode($systemName));
        }
        catch(DBException $dbE) {
            $this->_error($dbE->getMessage());
        }
    }

    public function edit($systemName=NULL,$portName=NULL) {
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
        $navModes['CANCEL'] = "/switchport/view/".rawurlencode(self::$sys->get_system_name())."/".rawurlencode($portName);
        $navbar = new Navbar("Edit Switchport", $navModes, null);

        // Load view data
        $info['header'] = $this->load->view('core/header',"",TRUE);
        $info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
        $info['title'] = "Edit Switchport";
        $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
        $viewData['sPort'] = $sPort;
        $viewData['sys'] = self::$sys;
        try {
            $viewData['types'] = $this->api->network->get->types();
        }
        catch (DBException $dbE) {
            $this->_error("No switchport types configured?");
        }
        $info['data'] = $this->load->view('switchport/edit',$viewData,TRUE);

        // Load the main view
        $this->load->view('core/main',$info);
    }
}
/* End of file switchport.php */
/* Location: ./application/controllers/switchport.php */