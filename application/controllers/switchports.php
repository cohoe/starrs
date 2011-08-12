<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Switchports extends ImpulseController {

   # public static $sPort;

    public function view($systemName=NULL) {
        if($systemName==NULL) {
            $this->_error("No system specified for viewing");
        }

        $systemName = rawurldecode($systemName);
        try {
            $this->_load_system($systemName);
        }
        catch(ObjectNotFoundException $onfE) {
            $this->_error("Unable to find system \"$systemName\"");
        }
        try {
            $this->_load_switchports($systemName);
            $viewData = $this->_get_switchport_view_data();
        }
        catch(ObjectNotFoundException $onfE) {
            $viewData = $this->_warning("No switchports configured!");
        }

        // Navbar
        $navModes['CREATE'] = "/switchports/create/".rawurlencode(self::$sys->get_system_name());
        $navOptions['System'] = "/systems/view/".rawurlencode(self::$sys->get_system_name());
        $navOptions['Switchview'] = '/switchview/settings/'.rawurlencode(self::$sys->get_system_name());
        $navbar = new Navbar("Switchports on ".self::$sys->get_system_name(), $navModes, $navOptions);

        // Load view data
        $info['header'] = $this->load->view('core/header',"",TRUE);
        $info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
        $info['title'] = "Switchports on ".self::$sys->get_system_name();
        $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
        $info['data'] = $viewData;

        // Load the main view
        $this->load->view('core/main',$info);
    }

    public function create($systemName=NULL) {
        if($systemName==NULL) {
            $this->_error("No system specified for create");
        }

        $this->_load_system(urldecode($systemName));

        if($this->input->post('submit')) {
            if($this->input->post('portname')) {
                try {
                    $sPort = $this->api->network->create->switchport(
                        $this->input->post('portname'),
                        $this->input->post('system_name'),
                        $this->input->post('type'),
                        $this->input->post('description')
                    );

                    self::$sys->add_switchport($sPort);
                }
                catch (DBException $dbE) {
                    $this->_error($dbE->getMessage());
                }
                catch(AmbiguousTargetException $atE) {
                    $this->_error($atE->getMessage());
                }
            }
            else {
                //$prefix, $firstNumber, $lastNumber, $systemName, $type, $description
                try {
                    $sPorts = $this->api->network->create->switchport_range(
                        $this->input->post('prefix'),
                        $this->input->post('first_num'),
                        $this->input->post('last_num'),
                        $this->input->post('system_name'),
                        $this->input->post('type'),
                        $this->input->post('description')
                    );

                    foreach($sPorts as $sPort) {
                        self::$sys->add_switchport($sPort);
                    }
                }
                catch (DBException $dbE) {
                    $this->_error($dbE->getMessage());
                }
            }

            // Set the system object
			$this->impulselib->set_active_system(self::$sys);
			self::$sidebar->reload();
            redirect(base_url()."switchports/view/".rawurlencode(self::$sys->get_system_name()),'location');
        }
        else {
            // Navbar
            $navModes['CANCEL'] = "/switchports/view/".rawurlencode(self::$sys->get_system_name());
            $navbar = new Navbar("Create Switchport", $navModes, null);

            // Load view data
            $info['header'] = $this->load->view('core/header',"",TRUE);
            $info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
            $info['title'] = "Create Switchport";
            $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
            $form['sys'] = self::$sys;
            try {
                $form['types'] = $this->api->network->get->types();
            }
            catch (DBException $dbE) {
                $this->_error("No switchport types configured?");
            }
            $info['data'] = $this->load->view('switchports/create',$form,TRUE);

            // Load the main view
            $this->load->view('core/main',$info);
        }
    }

    private function _get_switchport_view_data() {
        $sPorts = self::$sys->get_switchports();
        if(count($sPorts) != 0) {
            $viewData = $this->load->view('switchports/grid',array("sPorts"=>$sPorts),TRUE);
        }
        else {
            $viewData = $this->_warning("No switchports configured!");
        }
        
        return $viewData;
    }
    private function _get_system($systemName) {
        try {
            self::$sys = $this->api->systems->get->system($systemName);
        }
        catch (ObjectNotFoundException $onfE) {
            $this->_error("System \"$systemName\" not found.");
        }
        catch (DBException $dbE) {
            $this->_error($dbE->getMessage());
        }
    }
}
/* End of file switchports.php */
/* Location: ./application/controllers/switchports.php */