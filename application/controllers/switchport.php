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
        self::$sPort = self::$sys->get_switchport(rawurldecode($portName));

        // Navbar
        $navModes['EDIT'] = "/switchport/edit/".rawurlencode(self::$sys->get_system_name())."/".rawurlencode($portName);
        $navModes['DELETE'] = "/switchport/delete/".rawurlencode(self::$sys->get_system_name())."/".rawurlencode(self::$sPort->get_port_name());
        $navOptions['Switchports'] = "/switchports/view/".rawurlencode(self::$sys->get_system_name());
        $navbar = new Navbar("Switchport Details", $navModes, $navOptions);

        // Load view data
        $info['header'] = $this->load->view('core/header',"",TRUE);
        $info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
        $info['title'] = "Switchport Details";
        $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
        $viewData['sPort'] = self::$sPort;
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

        $this->_load_system(rawurldecode($systemName));
        $this->_load_switchports(rawurldecode($systemName));
        try {
            exit(rawurldecode($portName));
            self::$sPort = self::$sys->get_switchport(rawurldecode($portName));
        }
        catch(ObjectException $oE) {
            $this->_error($oE->getMessage());
        }

        if($this->input->post('submit')) {
            try {
                $this->_edit();
                redirect(base_url()."switchport/view/".rawurlencode(self::$sys->get_system_name())."/".rawurlencode(self::$sPort->get_port_name()),'location');
            }
            catch(ObjectNotFoundException $oE) {
                $this->_error($oE->getMessage());
            }
        }
        else {
            // Navbar
            $navModes['CANCEL'] = "/switchport/view/".rawurlencode(self::$sys->get_system_name())."/".rawurlencode($portName);
            $navbar = new Navbar("Edit Switchport", $navModes, null);

            // Load view data
            $info['header'] = $this->load->view('core/header',"",TRUE);
            $info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
            $info['title'] = "Edit Switchport";
            $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
            $viewData['sPort'] = self::$sPort;
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

    private function _edit() {
        $err = "";
        if(self::$sPort->get_system_name() != $this->input->post('system_name')) {
            try { self::$sPort->set_system_name($this->input->post('system_name')); }
            catch(Exception $e) { $err .= $e->getMessage(); }
        }
        if(self::$sPort->get_port_name() != $this->input->post('port_name')) {
            try { self::$sPort->set_port_name($this->input->post('port_name')); }
            catch(Exception $e) { $err .= $e->getMessage(); }
        }
        if(self::$sPort->get_type() != $this->input->post('type')) {
            try { self::$sPort->set_type($this->input->post('type')); }
            catch(Exception $e) { $err .= $e->getMessage(); }
        }
        if(self::$sPort->get_description() != $this->input->post('description')) {
            try { self::$sPort->set_description($this->input->post('description')); }
            catch(Exception $e) { $err .= $e->getMessage(); }
        }
        if(self::$sPort->get_admin_state() != $this->input->post('enable')) {
            try { self::$sPort->set_admin_state($this->input->post('enable')); }
            catch(Exception $e) { $err .= $e->getMessage(); }
        }

        if($err != "") {
            $this->_error($err);
        }
    }
}
/* End of file switchport.php */
/* Location: ./application/controllers/switchport.php */