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

	/**
     * Delete an address on an interface
     * @param null $mac     The MAC address of the interface
     * @param null $address The address of the interface to delete
     * @return void
     */
	public function delete($address=NULL) {

        // If the user forgot to specify something
		if($mac == NULL) {
			$this->_error("No interface specified!");
		}

		#$mac = rawurldecode($mac);
		$address = rawurldecode($address);
		
        #try {
			#self::$int = $this->api->systems->get->system_interface_data($mac,true);
			#self::$sys = $this->_load_system(self::$int->get_system_name());
			
        #}
        #catch (APIException $apiE) {
        #    $this->_error($apiE->getMessage());
        #}
		
		// Information is there. Delete the address
		if($this->input->post('submit')) {
			try {
				$this->api->systems->remove->interface_address($this->input->post('address'));
				self::$addr = $this->api->systems->get->system_interface_address($address);
				self::$int = $this->api->systems->get->system_interface_data(self::$addr->get_mac(),true);
				self::$sys->add_interface(self::$int);
				$this->impulselib->set_active_system(self::$sys);
				self::$sidebar->reload();
				redirect(base_url()."interfaces/addresses/".rawurlencode(self::$int->get_mac()),'location');
			}
			catch(Exception $e) {
				$this->_error($e->getMessage());
			}
		}
        
        // Navbar
        $navModes['CANCEL'] = "";
        $navbar = new Navbar("Delete Address", $navModes, null);

        // Load the view data
        $info['header'] = $this->load->view('core/header',"",TRUE);
        $info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
        $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);

        // Get the preset form data for drop down lists and things
        $form['interface'] = self::$int;
        $form['addresses'] = self::$int->get_interface_addresses();
        $form['address'] = $address;

        // Are you an admin?
        if($this->api->isadmin() == TRUE) {
            $form['admin'] = TRUE;
        }

        // Continue loading view data
        $info['data'] = $this->load->view('addresses/delete',$form,TRUE);
        $info['title'] = "Delete Address";

        // Load the main view
        $this->load->view('core/main',$info);
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
			$navModes['CREATE'] = "/interface/create/".rawurlencode(self::$sys->get_system_name());
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
                $navOptions['Addresses'] = "/addresses/view/".rawurlencode($int->get_mac());
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