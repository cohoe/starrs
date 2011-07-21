<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

/**
 * Interface addreses. Create/Edit/Delete/View all information and objects that are based on the InterfaceAddresses
 */
class Addresses extends ImpulseController {

    /**
     * View an address on an interface
     * @param null $mac     The MAC address of the interface that the address is on
     * @param null $address The address to view
     * @param null $target  The view that we want
     * @return void
     */
	public function view($address=NULL,$target=NULL) {

        // If the user tried to do something silly
		if($address==NULL) {
			$this->_error("No IP address specified!");
			return;	
		}

        // Establish the interface
        try {
            $sys = $this->impulselib->get_active_system();
			$int = $sys->get_interface($this->api->ip->arp($address));
        }
        catch (ObjectNotFoundException $onfE) {
            $this->_error($onfE->getMessage());
            return;
        }
		catch (ObjectException $oE) {
			$this->_error($oE->getMessage());
            return;
		}

		if(!($int instanceof NetworkInterface)) {
			$this->_error("No interface could be found. Click Systems on the left to try again");
			return;
		}
        try {
		    $addr = $int->get_address($address);
        }
        catch (APIException $apiE) {
            $this->_error($apiE->getMessage());
            return;
        }
		
		// Navbar
		$navOptions['Overview'] = "/addresses/view/".$addr->get_address();
		$navOptions['DNS Records'] = "/dns/view/".$addr->get_address();
		$navOptions['Firewall Rules'] = "/firewall/view/".$addr->get_address();
		$navModes['EDIT'] = "/addresses/edit/".$addr->get_address();
		$navModes['DELETE'] = "/addresses/delete/".$addr->get_mac()."/".$addr->get_address();
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['title'] = "Overview - ".$addr->get_address();
		$viewData['address'] = $addr;
		$navbar = new Navbar("Address Overview", $navModes, $navOptions);

        // More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('addresses/overview', $viewData, TRUE);

		// Load the main view
		$this->load->view('core/main',$info);
	}

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

        // Get the interface object
		#$int = $this->impulselib->get_active_interface($mac);
        $sys = $this->impulselib->get_active_system();
        $int = $sys->get_interface($mac);
		
		// Information is there. Create the address
		if($this->input->post('submit')) {
			// Create the address
			$addr = $this->_create();
			
			// Check if it actually worked
			if(!($addr instanceof InterfaceAddress)) {
				return;
			}
			
			// Update our stuff
			$int->add_address($addr);
            $sys->add_interface($int);
			$this->impulselib->set_active_system($sys);
			
			// Send you on your way
            redirect(base_url()."/interfaces/addresses/".$int->get_mac()."/".$addr->get_address(),'location');
		}
        
        // Navbar
        $navModes['CANCEL'] = "";
        $navbar = new Navbar("Create Address", $navModes, null);

        // Load the view data
        $info['header'] = $this->load->view('core/header',"",TRUE);
        $info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
        $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);

        // Get the preset form data for drop down lists and things
        $form['interface'] = $int;
        $form['ranges'] = $this->api->ip->get_ranges();
        $form['configs'] = $this->api->dhcp->get_dhcp_config_types();
        $form['classes'] = $this->api->dhcp->get_dhcp_classes();

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
     * Delete an address on an interface
     * @param null $mac     The MAC address of the interface
     * @param null $address The address of the interface to delete
     * @return void
     */
	public function delete($mac=NULL,$address=NULL) {

        // If the user forgot to specify something
		if($mac == NULL) {
			$this->_error("No interface specified!");
		}

        $sys = $this->impulselib->get_active_system();
        $int = $sys->get_interface($mac);
		
		// Information is there. Delete the address
		if($this->input->post('submit')) {
			$addr = $int->get_address($this->input->post('address'));
			$this->_delete($addr);
            redirect(base_url()."interfaces/addresses/".$addr->get_mac(),'location');
		}
        
        // Navbar
        $navModes['CANCEL'] = "";
        $navbar = new Navbar("Delete Address", $navModes, null);

        // Load the view data
        $info['header'] = $this->load->view('core/header',"",TRUE);
        $info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
        $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);

        // Get the preset form data for drop down lists and things
        $form['interface'] = $int;
        $form['addresses'] = $int->get_interface_addresses();
        $form['address'] = $address;

        // Are you an admin?
        if($this->api->isadmin() == TRUE) {
            $form['admin'] = TRUE;
        }

        // Continue loading view data
        $info['data'] = $this->load->view('addresses/delete',$form,TRUE);
        $info['title'] = "Create Address";

        // Load the main view
        $this->load->view('core/main',$info);
	}
	
	public function edit($address=NULL) {
		// If the user forgot to specify something
		if($address == NULL) {
			$this->_error("No address specified!");
			return;
		}
		
		// Create the local interface object from the SESSION array.
		$sys = $this->impulselib->get_active_system();
        $int = $sys->get_interface($this->api->ip->arp($address));
		$addr = $int->get_address($address);
		
		// Information is there. Execute the edit
		if($this->input->post('submit')) {
			try {
				$this->_edit($addr);
				$int->add_address($addr);
				$sys->add_interface($int);
				$this->impulselib->set_active_system($sys);
			}
			catch (DBException $dbE) {
				$this->_error($dbE->getMessage());
				return;
			}
			
			redirect(base_url()."addresses/view/".$addr->get_address());
		}
		
		// Need to input the information
		else {
			// Navbar
			$navModes['CANCEL'] = "";
			$navbar = new Navbar("Edit Address", $navModes, null);
			
			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Get the preset form data for drop down lists and things
			$form['ranges'] = $this->api->ip->get_ranges();
			$form['configs'] = $this->api->dhcp->get_dhcp_config_types();
			$form['classes'] = $this->api->dhcp->get_dhcp_classes();
			$form['addr'] = $addr;

			// Are you an admin?
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}
			
			// Continue loading view data
			$info['data'] = $this->load->view('addresses/edit',$form,TRUE);
			$info['title'] = "Edit Address";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}

    /**
     * Create a new address
     * @param $int  The interface object to create
     * @return void
     */
	private function _create() {

        // Is this interface to be primary
		$isPrimary = ($this->input->post('isprimary')=='t'?"TRUE":"FALSE");

        // If no address was given, get one from the selected range
		$address = $this->input->post('address');
		if($address == "") {
			$address = $this->api->ip->get_address_from_range($this->input->post('range'));
		}

        // Call the create function
		try {
			$addr = $this->api->systems->create_interface_address(
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
			return;
		}
		catch (ObjectException $oE) {
			$this->_error("Obj:".$dbE->getMessage());
			return;
		}
		
		// Get the object
		return $addr;
	}
	
	private function _edit(&$addr) {
	
		$err = "";
		
		// If no address was given, get one from the selected range
		$address = $this->input->post('address');
		if($address == "") {
			$range = $this->input->post('range');
			if($range == "") {
				$range = $addr->get_range();
			}
			$address = $this->api->ip->get_address_from_range($range);
			try { $addr->set_address($address); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		elseif($addr->get_address() != $this->input->post('address')) {
			try { $addr->set_address($this->input->post('address')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if($addr->get_config() != $this->input->post('config')) {
			try { $addr->set_config($this->input->post('config')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if($addr->get_class() != $this->input->post('class')) {
			try { $addr->set_class($this->input->post('class')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if($addr->get_isprimary() != $this->input->post('isprimary')) {
			try { $addr->set_isprimary($this->input->post('isprimary')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if($addr->get_comment() != $this->input->post('comment')) {
			try { $addr->set_comment($this->input->post('comment')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}

		// If there were/were not errors
		if($err != "") {
			$this->_error($err);
			return;
		}
	}

    /**
     * Delete an address
     * @param $addr The address object to delete
     * @return void
     */
	private function _delete($addr) {

        // Call the query function
		try {
			$this->api->systems->remove_interface_address($addr);
		}
		catch (DBException $dbE) {
			$this->_error("DB:".$dbE->getMessage());
			return;
		}
		catch (ObjectException $oE) {
			$this->_error("Obj:".$dbE->getMessage());
			return;
		}
	}
}

/* End of file addresses.php */
/* Location: ./application/controllers/addresses.php */
