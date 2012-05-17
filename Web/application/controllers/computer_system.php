<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

/**
 * This controller handles all information regarding the system objects. You can create, edit, and delete systems
 * that you have permission to do so on. 
 */
class Computer_system extends ImpulseController {
	
    /**
	 * If no additional URL paramters were specified, load this default view
     * @return void
     */
	public function index() {
		$this->_error("What would you like to do today dirtbag?");
	}

    /**
	 * View a specific systems information. 
     * @param null $systemName	The name of the system to view
     * @param null $target		The target view. Right now this is just an overview and the interfaces
     * @return void
     */
	public function view($systemName=NULL) {
		$systemName = rawurldecode($systemName);		
		if($systemName == NULL) {
			$this->_error("No system specified for viewing");
		}
		
		// System Object
		try {
			self::$sys = $this->_load_system($systemName);
		}
		catch (ObjectNotFoundException $oNFE) {
			$this->_error("System not found!");
		}
		catch(DBException $dbE) {
			$this->_error("Error viewing system: ".$dbE->getMessage());
		}
		
		// Navbar information
		$navModes = array();
		$navOptions['Interfaces'] = "/interfaces/view/".rawurlencode(self::$sys->get_system_name());
		
		if($this->impulselib->get_username() == self::$sys->get_owner() || $this->api->isadmin() == TRUE) {
			$navOptions['Renew'] = "/system/renew/".rawurlencode(self::$sys->get_system_name());
			$navModes['EDIT'] = "/system/edit/".rawurlencode(self::$sys->get_system_name());
			$navModes['DELETE'] = "/system/delete/".rawurlencode(self::$sys->get_system_name());
		}
		
		if(self::$sys->get_family() == "Network") {
			$navOptions['Switchports'] = '/switchports/view/'.rawurlencode(self::$sys->get_system_name());
			$navOptions['Switchview'] = '/switchview/settings/'.rawurlencode(self::$sys->get_system_name());
		}
		
		$navbar = new Navbar(self::$sys->get_system_name(), $navModes, $navOptions);

		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['title'] = "System - ".self::$sys->get_system_name();
		$info['data'] = $this->load->view('systems/system',array('system'=>self::$sys),TRUE);
		
		// Load the main view
		$this->load->view('core/main',$info);
		
		// Set the system object
		$this->impulselib->set_active_system(self::$sys);
	}

    /**
	 * Edit the properties of an existing system
     * @return void
     */
	public function edit($systemName=NULL) {
		if($systemName == NULL) {
			$this->_error("No system name specified for editing.");
		}
		$systemName = rawurldecode($systemName);

		// Get the system object that we will be editing
		self::$sys = $this->_load_system($systemName);
		
		// Information is there. Execute the edit
		if($this->input->post('submit')) {
			$this->_edit();
			$this->impulselib->set_active_system(self::$sys);
			self::$sidebar->reload();
			redirect(base_url()."system/view/".rawurlencode(self::$sys->get_system_name()),'location');
		}
		
		// Need to input the information
		else {
			// Navbar
			$navModes['CANCEL'] = "/system/view/".rawurlencode(self::$sys->get_system_name());
			$navbar = new Navbar("Edit System", $navModes, null);
			
			// Get the preset form data for dropdown lists and things
			$form['operatingSystems'] = $this->api->systems->get->operating_systems();
			$form['systemTypes'] = $this->api->systems->get->system_types();
			$form['system'] = self::$sys;
			$form['user'] = $this->impulselib->get_username();
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}
			
			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $this->load->view('systems/edit',$form,TRUE);
			$info['title'] = "Edit System";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
		
		// Set the active SESSION object
		$this->impulselib->set_active_system(self::$sys);
	}

    /**
	 * Create a new system in the database
     * @return void
     */
	public function create() {
	
		// Information is there. Create the system
		if($this->input->post('submit')) {
			$this->_create();
			$this->impulselib->set_active_system(self::$sys);
			self::$sidebar->reload();
			redirect(base_url()."system/view/".rawurlencode(self::$sys->get_system_name()),'location');
		}
		
		// Need to input the information
		else {
			// Navbar
            $navModes['CANCEL'] = "/systems/view/owned";
            $navbar = new Navbar("Create System", $navModes, null);

			// Get the preset form data for dropdown lists and things
			$form['operatingSystems'] = $this->api->systems->get->operating_systems();
			$form['user'] = $this->api->get->current_user();
			$form['systemTypes'] = $this->api->systems->get->system_types();
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}
			
			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $this->load->view('systems/create',$form,TRUE);
			$info['title'] = "Create System";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}

    /**
	 * Delete a system in the DB (as long as you own it!)
     * @return void
     */
	public function delete($systemName=NULL) {
		if($systemName == NULL) {
			$this->_error("No system name was given for delete");
		}
		$systemName = rawurldecode($systemName);
		
		// They hit yes, delete the system
		if($this->input->post('yes')) {
			try {
				$this->api->systems->remove->system($systemName);
			}
			catch (Exception $e) {
				$this->_error("Could not delete system: {$e->getMessage()}");
			}
			self::$sidebar->reload();
			$this->impulselib->set_active_system(NULL);
			redirect(base_url()."systems/view/owned","location");
		}
		
		// They hit no, don't delete the system
		elseif($this->input->post('no')) {
			redirect(base_url()."system/view/{$systemName}",'location');
		}
		
		// Need to print the prompt
		else {
			// Navbar
            $navModes['CANCEL'] = "/system/view/".rawurlencode($systemName);
			$navbar = new Navbar("Delete System", $navModes, null);
			
			// Load the prompt information
			$prompt['message'] = "Delete system \"{$systemName}\" and all associated records?";
			$prompt['rejectUrl'] = $this->input->server('HTTP_REFERER');
			
			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $this->load->view('core/prompt',$prompt,TRUE);
			$info['title'] = "Delete System";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	/**
	 * Renew a system registration for another year. This is to help remove dead registrations and keep the DB clean
     * @return void
     */
	public function renew($systemName=NULL) {
		if($systemName == NULL) {
			$this->_error("No system name was given for delete");
		}
		$systemName = rawurldecode($systemName);
	
		// Get the current system object
		self::$sys = $this->_load_system($systemName);
		
		// Renew
		try {
			$this->api->systems->renew($systemName);
			$this->_success("Successfully renewed \"{$systemName}\" for another year.");
		}
		catch (Exception $e) {
			$this->_error("Unable to renew system: {$e->getMessage()}");
		}
	}
	
	public function quickcreate() {
		if($this->input->post('submit')) {
			$address = $this->input->post('address');
			if($address == "") {
				$address = $this->api->ip->get->address_from_range($this->input->post('range'));
			}
			
			try {
				$this->api->systems->create->system_quick($this->input->post('systemName'), $this->input->post('osName'), $this->input->post('mac'), $address, $this->input->post('owner'));
				redirect(base_url()."system/view/".rawurlencode($this->input->post('systemName')),'location');
			}
			catch(Exception $e) {
				$this->_error("Could not quickly create system: {$e->getMessage()}");
			}
		}
		
		// Navbar
		$navModes['CANCEL'] = "/systems/view/owned";
		$navbar = new Navbar("Quick Create System", $navModes, null);
		
		// Get the preset form data for dropdown lists and things
		$form['operatingSystems'] = $this->api->systems->get->operating_systems();
		$form['systemTypes'] = $this->api->systems->get->system_types();
		$form['user'] = $this->api->get->current_user();
		$form['ranges'] = $this->api->ip->get->ranges();
		if($this->api->isadmin() == TRUE) {
			$form['admin'] = TRUE;
		}
		
		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('systems/quickcreate',$form,TRUE);
		$info['title'] = "Quick Create System";
		
		// Load the main view
		$this->load->view('core/main',$info);
	}

    /**
	 * Create a system from the given values. 
     * @return void
     */
	private function _create() {
		try {
			self::$sys = $this->api->systems->create->system(
				$this->input->post('systemName'),
				$this->input->post('owner'),
				$this->input->post('type'),
				$this->input->post('osName'),
				$this->input->post('comment')
			);
			
			if(!(self::$sys instanceof System)) {
				throw new APIException("Could not instantate your system.");
			}
		}
		catch(Exception $e) {
			$this->_error("Could not create system: {$e->getMessage()}");
		}
	}

    /**
	 * Edit an existing system
     * @param $sys
     * @return void
     */
	private function _edit() {
		
		// The error return message
		$err = "";
		
		// Check for which field was modified
		if(self::$sys->get_system_name() != $this->input->post('systemName')) {
			try { self::$sys->set_system_name($this->input->post('systemName')); }
			catch (DBException $apiE) { $err .= $apiE->getMessage(); }
		}
		if(self::$sys->get_type() != $this->input->post('type')) {
			try { self::$sys->set_type($this->input->post('type')); }
			catch (DBException $apiE) { $err .= $apiE->getMessage(); }
		}
		if(self::$sys->get_os_name() != $this->input->post('osName')) {
			try { self::$sys->set_os_name($this->input->post('osName')); }
			catch (DBException $apiE) { $err .= $apiE->getMessage(); }
		}
		if(self::$sys->get_comment() != $this->input->post('comment')) {
			try { self::$sys->set_comment($this->input->post('comment')); }
			catch (DBException $apiE) { $err .= $apiE->getMessage(); }
		}
		if(self::$sys->get_owner() != $this->input->post('owner')) {
			try { self::$sys->set_owner($this->input->post('owner')); }
			catch (DBException $apiE) { $err .= $apiE->getMessage(); }
		}
		
		if($err != "") {
			$this->_error($err);
		}
	}
}
/* End of file computer_system.php */
/* Location: ./application/controllers/computer_system.php */
