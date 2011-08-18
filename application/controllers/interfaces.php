<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

/**
 * Network Interface handling. These functions will handle the editing of the actual interface objects.
 */
class Interfaces extends ImpulseController {

    /**
     * @return void
     */
	public function index() {
		$this->_error("No action or object was specified.");
	}


	public function view($systemName=NULL) {
		// If the user tried to do something silly.
		if($systemName == NULL) {
			   	$this->_error("No system was specified");
		}
		$systemName = rawurldecode($systemName);

		// Create the local system object from the SESSION array.
		try {
			  self::$sys = $this->_load_system($systemName);
		}
		catch(Exception $e) {
			   	$this->_error("Unable to instantiate system/interface objects - ".$e->getMessage());
		}

		$navModes = array();
		if($this->impulselib->get_username() == self::$sys->get_owner() || $this->api->isadmin() == TRUE) {
			$navModes['CREATE'] = "/interfaces/create/".rawurlencode(self::$sys->get_system_name());
		}
		
		$navOptions['System'] = "/systems/view/".rawurlencode(self::$sys->get_system_name());
		$navbar = new Navbar(self::$sys->get_system_name()." - Interfaces", $navModes, $navOptions);
		
		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['title'] = "System - ".self::$sys->get_system_name();
		$info['data'] = $this->_load_interfaces(self::$sys);
		
		// Load the main view
		$this->load->view('core/main',$info);
		
		// Set the system object
		$this->impulselib->set_active_system(self::$sys);
	}

private function _load_interfaces($sys) {
        // Value of all interface view data
        $interfaceViewData = "";

        // Get the interface objects for the system
        try {
            $ints = $this->api->systems->get->system_interfaces(self::$sys->get_system_name(),false);

            // Concatenate all view data into one string
            foreach ($ints as $int) {

                // Navbar
                if($this->impulselib->get_username() == $sys->get_owner() || $this->api->isadmin() == TRUE) {
                    $navModes['EDIT'] = "/interface/edit/".rawurlencode($int->get_mac());
                    $navModes['DELETE'] = "/interface/delete/".rawurlencode($int->get_mac());
                }
                $navOptions['Addresses'] = "/interface/addresses/".rawurlencode($int->get_mac());
                $navbar = new Navbar("Interface", $navModes, $navOptions);

                $interfaceViewData .= $this->load->view('systems/interfaces',array('interface'=>$int, 'navbar'=>$navbar),TRUE);

                #$this->impulselib->add_active_interface($interface);
                # Should be using the system object
                $sys->add_interface($int);
            }
        }
        catch (ObjectNotFoundException $onfE) {
            $navbar = new Navbar("Interface", null, null);
            $interfaceViewData = $this->load->view('core/warning',array("message"=>"No interfaces found!"),TRUE);
        }

        // Spit back all of the interface data
        return $this->load->view('core/data',array('data'=>$interfaceViewData),TRUE);
    }
}
/* End of file interfaces.php */
/* Location: ./application/controllers/interfaces.php */
