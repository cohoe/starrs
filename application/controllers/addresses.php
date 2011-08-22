<?php if ( ! defined('BASEPATH')) 'No direct script access allowed';
require_once(APPPATH . "libraries/core/ImpulseController.php");

/**
 * Interface addresses. Create/Edit/Delete/View all information and objects that are based on the InterfaceAddresses
 */
class Addresses extends ImpulseController {

    /**
     * Create a new address on the interface
     * @param null $mac The MAC address of the interface to add on
     * @return void
     */
	public function create($mac=NULL) {

        // If the user forgot something
		if($mac == NULL) {
			$this->_error("No interface specified!");
		}
		
		$mac = rawurldecode($mac);
		
		// Get the interface object
		try {
			self::$int = $this->api->systems->get->system_interface_data($mac);
			self::$sys = $this->_load_system(self::$int->get_system_name());
        }
        catch (APIException $apiE) {
            $this->_error($apiE->getMessage());
        }
		
		// Information is there. Create the address
		if($this->input->post('submit')) {
			// Create the address
			try {
				self::$addr = $this->_create();
			}
			catch(Exception $e) {
				$this->_error($e->getMessage());
			}
			
			// Update our stuff
			self::$int->add_address(self::$addr);
            self::$sys->add_interface(self::$int);
			$this->impulselib->set_active_system(self::$sys);
			self::$sidebar->reload();
			
			// Send you on your way
            redirect(base_url()."address/view/".rawurlencode(self::$addr->get_address()),'location');
		}
        
        // Navbar
        $navModes['CANCEL'] = "";
        $navbar = new Navbar("Create Address", $navModes, null);

        // Load the view data
        $info['header'] = $this->load->view('core/header',"",TRUE);
        $info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
        $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);

        // Get the preset form data for drop down lists and things
        $form['interface'] = self::$int;
        $form['ranges'] = $this->api->ip->get->ranges();
        $form['configs'] = $this->api->dhcp->get->config_types();
        $form['classes'] = $this->api->dhcp->get->classes();

        // Are you an admin?
        if($this->api->isadmin() == TRUE) {
            $form['admin'] = TRUE;
        }

        // Continue loading view data
        $info['data'] = $this->load->view('addresses/create',$form,TRUE);
        $info['title'] = "Create Address";

        // Load the main view
        $this->load->view('core/main',$info);
	}

	/**
     * See the various addresses on the interface. 
     * @param null $mac The MAC address of the interface to view
     * @return
     */
	public function view($mac=NULL) {

        // If the user did something silly.
		if($mac ==  NULL) {
			$this->_error("No interface was given!");
		}
		
		$mac = rawurldecode($mac);

        // Define the local interface object
		try {
			self::$int = $this->api->systems->get->system_interface_data($mac);
		}
		catch(Exception $e) {
			$this->_error("Unable to instantiate system/interface objects - ".$e->getMessage());
		}

		// Navbar
		$navModes['CREATE'] = "/addresses/create/".rawurlencode($mac);
		$navOptions['Interfaces'] = "/interfaces/view/".rawurlencode(self::$int->get_system_name());
		$navbar = new Navbar("Addresses on " . $mac, $navModes, $navOptions);

		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->_load_addresses(self::$int);
		$info['title'] = "Addresses - $mac";
		
		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	/**
     * Create a new address
     * @return InterfaceAddress     The object of the new interface address
     */
	private function _create() {

        // Is this interface to be primary
		$isPrimary = ($this->input->post('isprimary')=='t'?"TRUE":"FALSE");

        // If no address was given, get one from the selected range
		$address = $this->input->post('address');
		if($address == "") {
			$address = $this->api->ip->get->address_from_range($this->input->post('range'));
		}

        // Call the create function
		try {
			$addr = $this->api->systems->create->interface_address(
				$this->input->post('mac'),
				$address,
				$this->input->post('config'),
				$this->input->post('class'),
				$isPrimary,
				$this->input->post('comment')
			);
		}
		catch (DBException $dbE) {
			$this->_error("DB:".$dbE->getMessage());
		}
		catch (ObjectException $oE) {
			$this->_error("Obj:".$oE->getMessage());
		}

		// Get the object
		return $addr;
	}
}
/* End of file addresses.php */
/* Location: ./application/controllers/addresses.php */