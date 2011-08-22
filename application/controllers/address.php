<?php if ( ! defined('BASEPATH')) 'No direct script access allowed';
require_once(APPPATH . "libraries/core/ImpulseController.php");

/**
 * Interface addresses. Create/Edit/Delete/View all information and objects that are based on the InterfaceAddresses
 */
class Address extends ImpulseController {

    /**
     * View an address on an interface
     * @param null $address     The IP address that we are working with
     * @param null $target  The view that we want
     * @return void
     */
	public function view($address=NULL) {

        // If the user tried to do something silly
		if($address==NULL) {
			$this->_error("No IP address specified!");
		}
		
		$address = rawurldecode($address);

        // Establish the address
        try {
			self::$addr = $this->api->systems->get->system_interface_address($address);
        }
        catch (APIException $apiE) {
            $this->_error($apiE->getMessage());
        }
		
		// Navbar
		$navOptions['Overview'] = "/addresses/view/".rawurlencode(self::$addr->get_address());
		$navOptions['DNS Records'] = "/dns/view/".rawurlencode(self::$addr->get_address());
		if(self::$addr->get_dynamic() == FALSE) {
			$navOptions['Firewall Rules'] = "/firewall/rules/view/".rawurlencode(self::$addr->get_address());
		}
		$navModes['EDIT'] = "/address/edit/".rawurlencode(self::$addr->get_address());
		$navModes['DELETE'] = "/address/delete/".rawurlencode(self::$addr->get_address());
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "Overview - ".self::$addr->get_address();
		$viewData['address'] = self::$addr;
		$navbar = new Navbar("Address Overview", $navModes, $navOptions);

        // More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('addresses/overview', $viewData, TRUE);

		// Load the main view
		$this->load->view('core/main',$info);
	}

    /**
     * Edit an interface address
     * @param null $address     The interface address that we are editing
     * @return void
     */
	public function edit($address=NULL) {
		// If the user forgot to specify something
		if($address == NULL) {
			$this->_error("No address specified!");
		}
		
		$address = rawurldecode($address);
		
		// Get the interface object
		try {
			self::$addr = $this->api->systems->get->system_interface_address($address);
			self::$int = $this->api->systems->get->system_interface_data(self::$addr->get_mac());
			self::$sys = $this->_load_system(self::$int->get_system_name());
        }
        catch (APIException $apiE) {
            $this->_error($apiE->getMessage());
        }
		catch(ObjectNotFoundException $onfE) {
			$this->_error($onfE->getMessage());
		}		
		
		// Create the local interface object from the SESSION array.
		
		
		// Information is there. Execute the edit
		if($this->input->post('submit')) {
			try {
				$this->_edit();
				self::$int->add_address(self::$addr);
				self::$sys->add_interface(self::$int);
				$this->impulselib->set_active_system(self::$sys);
				self::$sidebar->reload();
			}
			catch (DBException $dbE) {
				$this->_error($dbE->getMessage());
			}
			
			if(self::$addr->get_dynamic() == TRUE) {
				redirect(base_url()."addresses/view/".rawurlencode(self::$int->get_mac()),'location');
			}
			else {
				redirect(base_url()."address/view/".rawurlencode(self::$addr->get_address()),'location');
			}
			
		}
		
		// Need to input the information
		else {
			// Navbar
			$navModes['CANCEL'] = "";
			$navbar = new Navbar("Edit Address", $navModes, null);
			
			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Get the preset form data for drop down lists and things
			$form['ranges'] = $this->api->ip->get->ranges();
			$form['configs'] = $this->api->dhcp->get->config_types();
			$form['classes'] = $this->api->dhcp->get->classes();
			$form['addr'] = self::$addr;

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
     * Edit the actual interface address
     * @param $addr     The address object to edit
     */
	private function _edit() {
		$err = "";
		
		// If no address was given, get one from the selected range
		$address = $this->input->post('address');
		if($address == "") {
			$range = $this->input->post('range');
			if($range == "") {
				$range = self::$addr->get_range();
			}
			self::$address = $this->api->ip->get->address_from_range($range);
			try { self::$addr->set_address(self::$address); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		elseif(self::$addr->get_address() != $this->input->post('address')) {
			try { self::$addr->set_address($this->input->post('address')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if(self::$addr->get_config() != $this->input->post('config')) {
			try { self::$addr->set_config($this->input->post('config')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if(self::$addr->get_class() != $this->input->post('class')) {
			try { self::$addr->set_class($this->input->post('class')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if(self::$addr->get_isprimary() != $this->input->post('isprimary')) {
			try { self::$addr->set_isprimary($this->input->post('isprimary')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if(self::$addr->get_comment() != $this->input->post('comment')) {
			try { self::$addr->set_comment($this->input->post('comment')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}

		// If there were/were not errors
		if($err != "") {
			$this->_error($err);
		}
	}

	/**
     * Delete an address on an interface
     * @param null $mac     The MAC address of the interface
     * @param null $address The address of the interface to delete
     * @return void
     */
	public function delete($address=NULL) {

        // If the user forgot to specify something
		if($address == NULL) {
			$this->_error("No address specified!");
		}

		$address = rawurldecode($address);

        try {
			self::$addr = $this->api->systems->get->system_interface_address($address);
			$this->api->systems->remove->interface_address($address);
			self::$sidebar->reload();
			redirect(base_url()."addresses/view/".rawurlencode(self::$addr->get_mac()),'location');
        }
        catch (APIException $apiE) {
            $this->_error($apiE->getMessage());
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
			$this->api->systems->remove->interface_address($addr);
		}
		catch (DBException $dbE) {
			$this->_error("DB:".$dbE->getMessage());
		}
		catch (ObjectException $oE) {
			$this->_error("Obj:".$oE->getMessage());
		}
	}
}
/* End of file address.php */
/* Location: ./application/controllers/address.php */