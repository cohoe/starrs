<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/controller.php");

/**
 * Interface addreses. Create/Edit/Delete/View all information and objects that are based on the InterfaceAddresses
 */
class Addresses extends IMPULSE_Controller {

    /**
     * View an address on an interface
     * @param null $mac     The MAC address of the interface that the address is on
     * @param null $address The address to view
     * @param null $target  The view that we want
     * @return void
     */
	public function view($mac=NULL,$address=NULL,$target=NULL) {

        // If the user tried to do something silly
		if($mac==NULL) {
			$this->error("No interface specified!");
		}
		if($address==NULL) {
			$this->error("No IP address specified!");
		}

        // Establish the interface
        try {
            $sys = $this->impulselib->get_active_system();
        }
        catch (ObjectNotFoundException $onfE) {
            $this->error($onfE->getMessage());
            return;
        }

        $int = $sys->get_interface($mac);
        try {
		    $addr = $int->get_address($address);
        }
        catch (APIException $apiE) {
            $this->error($apiE->getMessage());
            return;
        }
		
		// Navbar
		$navOptions['Overview'] = "/addresses/view/".$addr->get_mac()."/".$addr->get_address()."/overview";
		$navOptions['DNS Records'] = "/dns/view/".$addr->get_address();
		$navOptions['Firewall Rules'] = "/addresses/view/".$addr->get_mac()."/".$addr->get_address()."/firewall";
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);

		$navModes = array();
		
        // Switch views depending on what the user wants
		switch($target) {
			case "dns":
				$viewData['address'] = $addr;
				$data = $this->load->view('dns/address', $viewData, TRUE);
				$info['title'] = "DNS - ".$addr->get_address();
				$navbar = new Navbar("DNS for ".$addr->get_address(), $navModes, $navOptions);
				break;
			case "firewall":
				$viewData['rules'] = $addr->get_rules();
				$viewData['deny'] = $addr->get_fw_default();
				$data = $this->load->view('firewall/address', $viewData, TRUE);
				$info['title'] = "Firewall Rules - ".$addr->get_address();
				$navbar = new Navbar("Firewall Rules for ".$addr->get_address(), $navModes, $navOptions);
				break;
			default:
				$navModes['EDIT'] = "/addresses/edit/".$addr->get_mac()."/".$addr->get_address();
				$navModes['DELETE'] = "/addresses/delete/".$addr->get_mac()."/".$addr->get_address();
				$viewData['address'] = $addr;
				$data = $this->load->view('addresses/overview', $viewData, TRUE);
				$info['title'] = "Overview - ".$addr->get_address();
				$navbar = new Navbar("Address Overview", $navModes, $navOptions);
				break;
		}

        // More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $data;

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
			$this->error("No interface specified!");
		}

        // Get the interface object
		#$int = $this->impulselib->get_active_interface($mac);
        $sys = $this->impulselib->get_active_system();
        $int = $sys->get_interface($mac);
		
		// Information is there. Create the address
		if($this->input->post('submit')) {
			$addr = $this->_create($int);
			if(!($addr instanceof InterfaceAddress)) {
				return;
			}
            $sys->add_interface($int);
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
        $form['configs'] = $this->api->dhcp->get_config_types();
        $form['classes'] = $this->api->dhcp->get_classes();

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
			$this->error("No interface specified!");
		}

        $sys = $this->impulselib->get_active_system();
        $int = $sys->get_interface($mac);
		#$int = $this->impulselib->get_active_interface($mac);
		
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
	
	public function edit($mac=NULL,$address=NULL) {
		// If the user forgot to specify something
		if($mac == NULL) {
			$this->error("No interface specified!");
			return;
		}
		if($address == NULL) {
			$this->error("No address specified!");
			return;
		}
		
		// Create the local interface object from the SESSION array.
		$sys = $this->impulselib->get_active_system();
        $int = $sys->get_interface($mac);
		$addr = $int->get_address($address);
		
		// Information is there. Execute the edit
		if($this->input->post('submit')) {
			$err = $this->_edit($addr);
			
			if($err == "") {
				// Update the session data
				$int->add_address($addr);
				$sys->add_interface($int);
				$this->impulselib->set_active_system($sys);
				redirect(base_url()."addresses/view/".$addr->get_mac()."/".$addr->get_address());
			}
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
			$form['configs'] = $this->api->dhcp->get_config_types();
			$form['classes'] = $this->api->dhcp->get_classes();
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
	private function _create($int) {

        // Is this interface to be primary
		$isPrimary = ($this->input->post('isprimary')=='t'?"TRUE":"FALSE");

        // If no address was given, get one from the selected range
		$address = $this->input->post('address');
		if($address == "") {
			$address = $this->api->ip->get_address_from_range($this->input->post('range'));
		}

        // Call the create function
		$query = $this->api->systems->create_interface_address(
			$int->get_mac(),
			$address,
			$this->input->post('config'),
			$this->input->post('class'),
			$isPrimary,
			$this->input->post('comment')
		);

        // Check for error
		if($query != "OK") {
			$this->error($query);
			return;
		}
		else {
			$addr = $this->api->systems->get_system_interface_address($address);
			$int->add_address($addr);
			return $addr;
		}
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
			$this->error($err);
		}
		
		return $err;
	}

    /**
     * Delete an address
     * @param $addr The address object to delete
     * @return void
     */
	private function _delete($addr) {

        // Call the query function
		$query = $this->api->systems->remove_interface_address($addr);

        // Check for error
		if($query != "OK") {
			$this->error($query);
		}
	}
}

/* End of file addresses.php */
/* Location: ./application/controllers/addresses.php */
