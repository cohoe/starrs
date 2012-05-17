<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

/**
 * Network Interface handling. These functions will handle the editing of the actual interface objects.
 */
class Network_interface extends ImpulseController {

    /**
     * @return void
     */
	public function index() {
		$this->_error("What would you like to do today dirtbag?");
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
        self::$sys = $this->_load_system($systemName);
		
        // Information is there. Create the system
        if($this->input->post('submit')) {
            $this->_create($systemName);
			
			// Add the interface
			self::$sys->add_interface(self::$int);
			$this->impulselib->set_active_system(self::$sys);
			self::$sidebar->reload();
			
			// Send you on your way
			#redirect(base_url()."interface/view/".rawurlencode(self::$int->get_mac()),'location');
			redirect(base_url()."interfaces/view/".rawurlencode(self::$sys->get_system_name()),'location');
        }
			
        // Need to input the information
        else {
            // Navbar
            $navModes['CANCEL'] = "/interfaces/view/".rawurlencode(self::$sys->get_system_name());
            $navbar = new Navbar("Create Interface", $navModes, null);

            // Get the preset form data for dropdown lists and things
            $form['systems'] = $this->api->systems->get->systems($this->impulselib->get_username());
            $form['systemName'] = $systemName;

            // If you are an administrator
            if($this->api->isadmin() == true) {
                $form['systems'] = $this->api->systems->get->systems(NULL);
                $form['admin'] = TRUE;
            }

            // Load the view data
            $info['header'] = $this->load->view('core/header',"",TRUE);
            $info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
            $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
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
			self::$sidebar->reload();
			
			// Send you on your way
			redirect(base_url()."interface/view/".rawurlencode(self::$int->get_mac()),'location');
		}
		
		// Need to input the information
		else {
			// Navbar
			$navModes['CANCEL'] = "/interface/view/".rawurlencode($mac);
			$navbar = new Navbar("Edit Interface", $navModes, null);
			
			// Get the preset form data for drop down lists and things
			$form['systems'] = $this->api->systems->get->systems($this->impulselib->get_username());
			if($this->api->isadmin() == true) {
				$form['systems'] = $this->api->systems->get->systems(NULL);
                $form['admin'] = TRUE;
			}
			$form['interface'] = self::$int;
			
			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
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
	public function delete($mac=NULL) {

        // If the user tried to do something silly. 
		if($mac == NULL) {
			$this->_error("No interface was specified");
		}
		$mac = rawurldecode($mac);
		
		// Define the local interface object
		try {
			self::$int = $this->api->systems->get->system_interface_data($mac);
		}
		catch(Exception $e) {
			$this->_error("Unable to instantiate system/interface objects - ".$e->getMessage());
		}
		
		// They hit yes, delete the system
		if($this->input->post('yes')) {
			// Run the query
			try {
				$this->api->systems->remove->_interface($mac);
			}
			catch (Exception $e) {
				$this->_error("Could not delete interface: {$e->getMessage()}");
			}
			
			self::$sidebar->reload();
			
			// Send you on your way
			redirect(base_url()."interfaces/view/".rawurlencode(self::$int->get_system_name()),'location');
		}
		
		// They hit no, don't delete the system
		elseif($this->input->post('no')) {
			redirect(base_url()."interface/view/".rawurlencode($mac),'location');
		}
		
		// Need to print the prompt
		else {
			// Navbar
            $navModes['CANCEL'] = "/interface/view/".rawurlencode($mac);
			$navbar = new Navbar("Delete Interface", $navModes, null);

			// Load the prompt information
			$prompt['message'] = "Delete interface \"".self::$int->get_interface_name()."\"?";
			$prompt['rejectUrl'] = $this->input->server('HTTP_REFERER');
			
			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $this->load->view('core/prompt',$prompt,TRUE);	// Systems
			$info['title'] = "Delete Interface \"".self::$int->get_interface_name()."\"";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
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
            $this->_error("No interface with MAC address \"{$mac}\" was found.");
        }
        catch(Exception $e) {
            $this->_error($e->getMessage());
        }
		
		$navOptions['Addresses'] = "/addresses/view/".rawurlencode($mac);
		try {
			self::$sPort = $this->api->systems->get->interface_switchport($mac);
			$navOptions['Switchport'] = "/switchport/view/".rawurlencode(self::$sPort->get_system_name())."/".rawurlencode(self::$sPort->get_port_name());
		}
		catch(ObjectNotFoundException $onfE) { }

        // Navbar
        $navModes['EDIT'] = "/interface/edit/".rawurlencode($mac);
        $navModes['DELETE'] = "/interface/delete/".rawurlencode($mac);
        $navbar = new Navbar("Interface - {$mac}", $navModes, $navOptions);

        // Load view data
        $info['header'] = $this->load->view('core/header',"",TRUE);
        $info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
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
	private function _create($systemName) {
        // Call the function
		try {
			self::$int = $this->api->systems->create->_interface(
				$systemName,
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
	}
	
    /**
     * Edit an interface
     * @param $int  The interface object to modify
     * @return void
     */
	private function _edit() {
		$err = "";
		
		if(self::$int->get_system_name() != $this->input->post('systemName')) {
			try { self::$int->set_system_name($this->input->post('systemName')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if(self::$int->get_interface_name() != $this->input->post('name')) {
			try { self::$int->set_interface_name($this->input->post('name')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if(self::$int->get_comment() != $this->input->post('comment')) {
			try { self::$int->set_comment($this->input->post('comment')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if(self::$int->get_mac() != $this->input->post('mac')) {
			try { self::$int->set_mac($this->input->post('mac')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}

        // If there were/were not errors
		if($err != "") {
			$this->_error($err);
		}
	}
}
/* End of file network_interface.php */
/* Location: ./application/controllers/network_interface.php */
