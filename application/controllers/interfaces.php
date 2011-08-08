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
     * Create a new network interface on a given system.
     * @param null $systemName  The name of the system to create the interface on
     * @return void
     */
	public function create($systemName=NULL) {

        // If the user tried to do something silly. 
		if($systemName == NULL) {
			$this->_error("No system was specified");
		}
		$systemName = rawurldecode($systemName);
		
		// Create the local system object from the SESSION array.
        $sys = $this->impulselib->get_active_system();
		try {
			self::$sys = $this->_load_system($systemName);
		}
		catch(Exception $e) {
			$this->_error("Unable to instantiate system/interface objects - ".$e->getMessage());
		}
		
        // Information is there. Create the system
        if($this->input->post('submit')) {
            self::$int = $this->_create();
			
			// Add the interface
			self::$sys->add_interface(self::$int);
			$this->impulselib->set_active_system(self::$sys);
			
			// Send you on your way
			redirect(base_url()."systems/view/".$this->input->post('systemName')."/interfaces",'location');
        }
			
        // Need to input the information
        else {
            // Navbar
            $navModes['CANCEL'] = "";
            $navbar = new Navbar("Create Interface", $navModes, null);

            // Load the view data
            $info['header'] = $this->load->view('core/header',"",TRUE);
            $info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
            $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);

            // Get the preset form data for dropdown lists and things
            $form['systems'] = $this->api->systems->get->systems($this->impulselib->get_username());
            $form['systemName'] = $systemName;

            // If you are an administrator
            if($this->api->isadmin() == true) {
                $form['systems'] = $this->api->systems->get->systems(NULL);
                $form['admin'] = TRUE;
            }

            // Continue loading view data
            $info['data'] = $this->load->view('interfaces/create',$form,TRUE);
            $info['title'] = "Create Interface";

            // Load the main view
            $this->load->view('core/main',$info);
        }
	}

    /**
     * Edit a system interface.
     * @param null $mac The MAC address of the interface to edit
     * @return void
     */
	public function edit($mac=NULL) {

        // If the user tried to do something silly. 
		if($mac == NULL) {
			$this->_error("No interface was specified");
		}
		$mac = rawurldecode($mac);

		// Define the local interface object
		try {
			self::$int = $this->api->systems->get->system_interface_data($mac);
			self::$sys = $this->_load_system(self::$int->get_system_name());
		}
		catch(Exception $e) {
			$this->_error("Unable to instantiate system/interface objects - ".$e->getMessage());
		}

		// Information is there. Execute the edit
		if($this->input->post('submit')) {
			$this->_edit(self::$int);
			
			// Update the session data
			self::$sys->add_interface(self::$int);
			$this->impulselib->set_active_system(self::$sys);
			
			// Semd ypi pm ypir wau
			redirect(base_url()."systems/view/".$this->input->post('systemName')."/interfaces",'location');
		}
		
		// Need to input the information
		else {
			// Navbar
			$navModes['CANCEL'] = "";
			$navbar = new Navbar("Edit Interface", $navModes, null);
			
			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Get the preset form data for drop down lists and things
			$form['systems'] = $this->api->systems->get->systems($this->impulselib->get_username());
			if($this->api->isadmin() == true) {
				$form['systems'] = $this->api->systems->get->systems(NULL);
                $form['admin'] = TRUE;
			}
			$form['interface'] = self::$int;
			
			// Continue loading view data
			$info['data'] = $this->load->view('interfaces/edit',$form,TRUE);
			$info['title'] = "Edit Interface";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}

    /**
     * Delete an interface from its MAC address. 
     * @param $mac  The MAC address of the interface to delete. 
     * @return void
     */
	public function delete($mac) {

        // If the user tried to do something silly. 
		if($mac == NULL) {
			$this->_error("No interface was specified");
		}
		
		$mac = rawurldecode($mac);

        // Establish the local interface object
		self::$int = $this->api->systems->get->system_interface_data($mac);
		
		// They hit yes, delete the system
		if($this->input->post('yes')) {
			$this->_delete(self::$int);
			// Send you on your way
			redirect(base_url()."systems/view/".self::$int->get_system_name()."/interfaces",'location');
		}
		
		// They hit no, don't delete the system
		elseif($this->input->post('no')) {
			redirect($this->input->post('url'),'location');
		}
		
		// Need to print the prompt
		else {
			// Navbar
            $navModes['CANCEL'] = "";
			$navbar = new Navbar("Delete Interface", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Load the prompt information
			$prompt['message'] = "Delete interface \"".self::$int->get_interface_name()."\"?";
			$prompt['rejectUrl'] = $this->input->server('HTTP_REFERER');
			
			// Continue loading the view data
			$info['data'] = $this->load->view('core/prompt',$prompt,TRUE);	// Systems
			$info['title'] = "Delete Interface \"".self::$int->get_interface_name()."\"";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}

    /**
     * See the various addresses on the interface. 
     * @param null $mac The MAC address of the interface to view
     * @return
     */
	public function addresses($mac=NULL) {

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
		$navModes['CREATE'] = "/addresses/create/".$mac;
		$navModes['DELETE'] = "/addresses/delete/".$mac;
		$navOptions['Interfaces'] = "/systems/view/".self::$int->get_system_name()."/interfaces";
		$navbar = new Navbar("Addresses on " . $mac, $navModes, $navOptions);

		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->_load_addresses(self::$int);
		$info['title'] = "Addresses - ".$mac;
		
		// Load the main view
		$this->load->view('core/main',$info);
	}

    public function view($mac=NULL) {
        if($mac==NULL) {
            $this->_error("No MAC address specified for view");
        }
        $mac = rawurldecode($mac);

        try {
            self::$int = $this->api->systems->get->system_interface_data($mac, false);
        }
        catch(ObjectNotFoundException $onfE) {
            $this->_error("No interface with MAC address \"$mac\" was found.");
        }
        catch(Exception $e) {
            $this->_error($e->getMessage());
        }
		
		$navOptions['Addresses'] = "/interfaces/addresses/".rawurlencode(self::$int->get_mac());
		try {
			self::$sPort = $this->api->systems->get->interface_switchport(self::$int->get_mac());
			$navOptions['Switchport'] = "/switchport/view/".rawurlencode(self::$sPort->get_system_name())."/".rawurlencode(self::$sPort->get_port_name());
		}
		catch(ObjectNotFoundException $onfE) { }

        // Navbar
        $navModes['EDIT'] = "/interfaces/edit/".rawurlencode(self::$int->get_mac());
        $navModes['DELETE'] = "/interfaces/delete/".rawurlencode(self::$int->get_mac());
        $navbar = new Navbar("Interface ".self::$int->get_mac(), $navModes, $navOptions);

        // Load view data
        $info['header'] = $this->load->view('core/header',"",TRUE);
        $info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
        $info['title'] = "Interface ".self::$int->get_mac();
        $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
        $info['data'] = $this->load->view('interfaces/view',array('int'=>self::$int),TRUE);

        // Load the main view
        $this->load->view('core/main',$info);
    }

    /**
     * Create an interface
     * @return void
     */
	private function _create() {
        // Call the function
		try {
			$int = $this->api->systems->create->_interface(
				$this->input->post('systemName'),
				$this->input->post('mac'),
				$this->input->post('name'),
				$this->input->post('comment')
			);
		}
        catch (DBException $dbE) {
			$this->_error("DB:".$dbE->getMessage());
			return;
		}
		catch (ObjectException $oE) {
			$this->_error("Obj:".$oE->getMessage());
		}
		
		return $int;
	}
	

    /**
     * Edit an interface
     * @param $int  The interface object to modify
     * @return void
     */
	private function _edit(&$int) {
		$err = "";
		
		if($int->get_system_name() != $this->input->post('systemName')) {
			try { $int->set_system_name($this->input->post('systemName')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if($int->get_interface_name() != $this->input->post('name')) {
			try { $int->set_interface_name($this->input->post('name')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if($int->get_comment() != $this->input->post('comment')) {
			try { $int->set_comment($this->input->post('comment')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if($int->get_mac() != $this->input->post('mac')) {
			try { $int->set_mac($this->input->post('mac')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}

        // If there were/were not errors
		if($err != "") {
			$this->_error($err);
		}
	}

    /**
     * Delete an interface
     * @param $int  The interface object to delete
     * @return void
     */
	private function _delete($int) {
        // Run the query
		try {
			$this->api->systems->remove->_interface($int);
		}
		catch (DBException $dbE) {
			$this->_error("DB:".$dbE->getMessage());
		}
		catch (ObjectException $oE) {
			$this->_error("Obj:".$oE->getMessage());
		}
	}

    /**
     * Load all of the interface address data. 
     * @param &$int  The interface object to add to. (WARNING: This does by ref, so be careful!)
     * @return string|void
     */
	private function _load_addresses(&$int) {

        // View data
		$addressViewData = "";

        // Array of address objects
		try {
			$addrs = $this->api->systems->get->system_interface_addresses($int->get_mac(), true);

			// For each of the address objects, draw it's box and append it to the view
			foreach($addrs as $addr) {
				$navOptions['DNS Records'] = "/dns/view/".$addr->get_address();
				if($addr->get_dynamic() != TRUE) {
					$navOptions['Firewall Rules'] = "/firewall/rules/view/".$addr->get_address();
				}
				$navModes['EDIT'] = "/addresses/edit/".$addr->get_address();
				$navModes['DELETE'] = "/addresses/delete/".$addr->get_mac()."/".$addr->get_address();
								
				$navbar = new Navbar("Address", $navModes, $navOptions);
				$addressViewData .= $this->load->view('systems/address',array('addr'=>$addr, 'navbar'=>$navbar),TRUE);
				$int->add_address($addr);
			}
			
			return $addressViewData;
		}
		// There were no addresses
		catch (ObjectNotFoundException $onfE) {
			return $this->_warning("No addresses found!");
		}
	}	
}

/* End of file interfaces.php */
/* Location: ./application/controllers/interfaces.php */
