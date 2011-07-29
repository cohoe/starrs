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
		
		// Create the local system object from the SESSION array.
        $sys = $this->impulselib->get_active_system();

        // Information is there. Create the system
        if($this->input->post('submit')) {
            $int = $this->_create();
			
			// Add the interface
			$sys->add_interface($int);
			
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
            $form['systems'] = $this->api->systems->get_systems($this->impulselib->get_username());
            $form['systemName'] = $systemName;

            // If you are an administrator
            if($this->api->isadmin() == true) {
                $form['systems'] = $this->api->systems->get_systems(NULL);
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

        // Create the local interface object from the SESSION array.
        $sys = $this->impulselib->get_active_system();
        $int = $sys->get_interface($mac);

		// Information is there. Execute the edit
		if($this->input->post('submit')) {
			$this->_edit($int);
			
			// Update the session data
			$sys->add_interface($int);
			$this->impulselib->set_active_system($sys);
			
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
			$form['systems'] = $this->api->systems->get_systems($this->impulselib->get_username());
			if($this->api->isadmin() == true) {
				$form['systems'] = $this->api->systems->get_systems(NULL);
                $form['admin'] = TRUE;
			}
			$form['interface'] = $int;
			
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

        // Establish the local interface object
		$int = $this->api->systems->get_system_interface_data($mac);
		
		// They hit yes, delete the system
		if($this->input->post('yes')) {
			$this->_delete($int);
			// Send you on your way
			redirect(base_url()."systems/view/".$int->get_system_name()."/interfaces",'location');
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
			$prompt['message'] = "Delete interface \"".$int->get_interface_name()."\"?";
			$prompt['rejectUrl'] = $this->input->server('HTTP_REFERER');
			
			// Continue loading the view data
			$info['data'] = $this->load->view('core/prompt',$prompt,TRUE);	// Systems
			$info['title'] = "Delete Interface \"".$int->get_interface_name()."\"";
			
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

        // Define the local interface object
		$sys = $this->impulselib->get_active_system();
		$int = $sys->get_interface($mac);		

		// Navbar
		$navModes['CREATE'] = "/addresses/create/".$mac;
		$navModes['DELETE'] = "/addresses/delete/".$mac;
		$navOptions['Interfaces'] = "/systems/view/".$int->get_system_name()."/interfaces";
		$navbar = new Navbar("Addresses on " . $mac, $navModes, $navOptions);

		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		
		$info['data'] = $this->_load_addresses($int);
		$info['title'] = "Addresses - ".$mac;
		
		// Load the main view
		$this->load->view('core/main',$info);
		
		// Update data
		$sys->add_interface($int);
		$this->impulselib->set_active_system($sys);
	}

    /**
     * Create an interface
     * @return void
     */
	private function _create() {
        // Call the function
		try {
			$int = $this->api->systems->create_interface(
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
			$this->_error("Obj:".$dbE->getMessage());
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
			$this->api->systems->remove_interface($int);
		}
		catch (DBException $dbE) {
			$this->_error("DB:".$dbE->getMessage());
		}
		catch (ObjectException $oE) {
			$this->_error("Obj:".$dbE->getMessage());
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
			$addrs = $this->api->systems->get_system_interface_addresses($int->get_mac(), true);

			// For each of the address objects, draw it's box and append it to the view
			foreach($addrs as $addr) {
				$navOptions['DNS Records'] = "/dns/view/".$addr->get_address();
				if($addr->get_dynamic() != TRUE) {
					$navOptions['Firewall Rules'] = "/firewall/view/".$addr->get_address();
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
