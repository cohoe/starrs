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
		$this->_error("What would you like to do today dirtbag?");
	}
	
	public function view($systemName=NULL) {
		if($systemName == NULL) {
			$this->_error("No system was specified");
		}
		$systemName = rawurldecode($systemName);

		// Create the local system object from the SESSION array.
		self::$sys = $this->_load_system($systemName);

		// Navbar
		$navOptions['System'] = "/system/view/".rawurlencode(self::$sys->get_system_name());
		$navModes = array();
		if($this->impulselib->iseditable(self::$sys)) {
			$navModes['CREATE'] = "/interface/create/".rawurlencode(self::$sys->get_system_name());
		}
		$navbar = new Navbar("Interfaces - {$systemName}", $navModes, $navOptions);
		
		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['title'] = "System - ".self::$sys->get_system_name();
		$info['data'] = $this->_load_interfaces();
		
		// Load the main view
		$this->load->view('core/main',$info);
		
		// Set the system object
		$this->impulselib->set_active_system(self::$sys);
	}

	private function _load_interfaces() {
        // Value of all interface view data
        $interfaceViewData = "";

        // Get the interface objects for the system
        try {
            // Concatenate all view data into one string
            foreach ($this->api->systems->get->system_interfaces(self::$sys->get_system_name(),false) as $int) {

                // Navbar
                if($this->impulselib->iseditable(self::$sys)) {
                    $navModes['EDIT'] = "/interface/edit/".rawurlencode($int->get_mac());
                    $navModes['DELETE'] = "/interface/delete/".rawurlencode($int->get_mac());
                }
                $navOptions['Addresses'] = "/addresses/view/".rawurlencode($int->get_mac());
                $navbar = new Navbar("Interface", $navModes, $navOptions);

                $interfaceViewData .= $this->load->view('systems/interfaces',array('interface'=>$int, 'navbar'=>$navbar),TRUE);

                self::$sys->add_interface($int);
            }
        }
        catch (ObjectNotFoundException $onfE) {
            $navbar = new Navbar("Interface", null, null);
            $interfaceViewData = $this->_warning("No interfaces found!");
        }

        // Spit back all of the interface data
        return $this->load->view('core/data',array('data'=>$interfaceViewData),TRUE);
    }
}
/* End of file interfaces.php */
/* Location: ./application/controllers/interfaces.php */