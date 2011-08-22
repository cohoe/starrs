<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

/**
 * This controller handles all information regarding the system objects. You can create, edit, and delete systems
 * that you have permission to do so on. 
 */
class Systems extends ImpulseController {
	
    /**
	 * If no additional URL paramters were specified, load this default view
     * @return void
     */
	public function index() {
	
		redirect(base_url()."systems/owned",'location');
	}

    /**
	 * View all of the systems registered in the IMPULSE database
     * @return void
     */
    public function all() {

		// Navbar
		$navModes['CREATE'] = "/systems/create";
		$navbar = new Navbar("Systems - All", $navModes, null);
		
		// List of systems
		try {
			$systemList = $this->api->systems->get->systems(NULL);
			$viewData = $this->load->view('systems/systemlist',array('systems'=>$systemList),TRUE);
		}
		catch (ObjectNotFoundException $onfE) {
			$viewData = $this->_warning("No systems found!");
		}

		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $viewData;
		$info['title'] = "All Systems";

		// Load the main view
		$this->load->view('core/main',$info);
	}

    /**
	 * View all of the systems that you are the owner for in the IMPULSE database
     * @return void
     */
    public function owned() {

		// Navbar
		$navModes['CREATE'] = "/systems/create";
		$navbar = new Navbar("Systems - Owned", $navModes, null);
		
		// List of systems
		try {
			$systemList = $this->api->systems->get->systems($this->impulselib->get_username());
			$viewData = $this->load->view('systems/systemlist',array('systems'=>$systemList),TRUE);
		}
		catch (ObjectNotFoundException $onfE) {
			$viewData = $this->_warning("No systems found!");
		}

		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $viewData;
		$info['title'] = "Owned Systems";
		$info['help'] = $this->load->view("help/systems/owned",null,TRUE);
		
		// Load the main view
		$this->load->view('core/main',$info);
	}

    /**
	 * View a specific systems information. 
     * @param null $systemName	The name of the system to view
     * @param null $target		The target view. Right now this is just an overview and the interfaces
     * @return void
     */
	public function view($systemName=NULL,$target=NULL) {
		$systemName = rawurldecode($systemName);
		$target = rawurldecode($target);

		if($systemName == NULL) {
			$this->_error("No system specified for viewing");
		}
		
		// We got a system, deal with it
		// If no target was specified, go to the overview page
		if($target == NULL) {
			$target = "overview";
		}
		
		// System Object
		try {
			$sys = $this->api->systems->get->system($systemName,false);
		}
		catch (ObjectNotFoundException $oNFE) {
			$this->_error("System not found!");
		}
            catch(DBException $dbE) {
                $this->_error("Error viewing system: ".$dbE->getMessage());
            }
		$systemViewData = $this->load->view('systems/system',array('system'=>$sys),TRUE);
		
		// Navbar information
		$navModes = array();
		#$navOptions['Overview'] = "/systems/view/".rawurlencode($sys->get_system_name())."/overview";
		$navOptions['Interfaces'] = "/interfaces/view/".rawurlencode($sys->get_system_name());
		
		if($this->impulselib->get_username() == $sys->get_owner() || $this->api->isadmin() == TRUE) {
			$navOptions['Renew'] = "/systems/renew/".rawurlencode($sys->get_system_name());
			$navModes['EDIT'] = "/systems/edit";
			$navModes['DELETE'] = "/systems/delete";
		}
		$navbar = new Navbar($sys->get_system_name(), $navModes, $navOptions);
		
		// Check for network system
		if($sys->get_family() == "Network") {
			$navbar->add_option('Switchports','/switchports/view/'.rawurlencode($sys->get_system_name()));
                $navbar->add_option('Switchview','/switchview/settings/'.rawurlencode($sys->get_system_name()));
		}
		
		// Figure out what page we are on and print accordingly
		switch(strtolower($target)) {
			case 'interfaces':
				$info['data'] = $this->_load_interfaces($sys);
				if($this->impulselib->get_username() == $sys->get_owner() || $this->api->isadmin() == TRUE) {
					$navbar->set_create(TRUE,"/interfaces/create".rawurlencode($sys->get_system_name()));
				}
				$navbar->set_edit(FALSE,NULL);
				$navbar->set_delete(FALSE,NULL);
				break;

			default:
				$info['data'] = $this->load->view('core/data',array('data'=>$systemViewData),TRUE);
				break;
		}
		
		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['title'] = "System - ".$sys->get_system_name();
		
		// Load the main view
		$this->load->view('core/main',$info);
		
		// Set the system object
		$this->impulselib->set_active_system($sys);
	}

    /**
	 * Edit the properties of an existing system
     * @return void
     */
	public function edit() {

		// Get the system object that we will be editing
		$sys = $this->impulselib->get_active_system();
		
		// Information is there. Execute the edit
		if($this->input->post('submit')) {
			$this->_edit($sys);
			self::$sidebar->reload();
			redirect(base_url()."systems/view/".rawurlencode($this->input->post('systemName')),'location');
		}
		
		// Need to input the information
		else {
			// Navbar
			$navModes['CANCEL'] = "";
			$navbar = new Navbar("Edit System", $navModes, null);
			
			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Get the preset form data for dropdown lists and things
			$form['operatingSystems'] = $this->api->systems->get->operating_systems();
			$form['systemTypes'] = $this->api->systems->get->system_types();
			$form['system'] = $sys;
			$form['user'] = $this->impulselib->get_username();
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}
			
			// Continue loading view data
			$info['data'] = $this->load->view('systems/edit',$form,TRUE);	// Systems
			$info['title'] = "Edit System";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
		
		// Set the active SESSION object
		$this->impulselib->set_active_system($sys);
	}

    /**
	 * Create a new system in the database
     * @return void
     */
	public function create() {
	
		// Information is there. Create the system
		if($this->input->post('submit')) {
			$sys = $this->_create();
			$this->impulselib->set_active_system($sys);
			self::$sidebar->reload();
			redirect(base_url()."systems/view/".rawurlencode($sys->get_system_name()),'location');
		}
		
		// Need to input the information
		else {
			// Navbar
            $navModes['CANCEL'] = "";
            $navbar = new Navbar("Create System", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Get the preset form data for dropdown lists and things
			$form['operatingSystems'] = $this->api->systems->get->operating_systems();
			$form['user'] = $this->api->get->current_user();
			
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}
			
			// Continue loading view data
			$info['data'] = $this->load->view('systems/create',$form,TRUE);	// Systems
			$info['title'] = "Create System";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}

    /**
	 * Delete a system in the DB (as long as you own it!)
     * @return void
     */
	public function delete() {
		
		// Get the current system object
		$sys = $this->impulselib->get_active_system();
		
		// They hit yes, delete the system
		if($this->input->post('yes')) {
			$this->_delete($sys);
			self::$sidebar->reload();
			redirect(base_url()."systems","location");
		}
		
		// They hit no, don't delete the system
		elseif($this->input->post('no')) {
			redirect($this->input->post('url'),'location');
		}
		
		// Need to print the prompt
		else {
			// Navbar
            $navModes['CANCEL'] = "";
			$navbar = new Navbar("Delete System", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Load the prompt information
			$prompt['message'] = "Delete system \"".$sys->get_system_name()."\"?";
			$prompt['rejectUrl'] = $this->input->server('HTTP_REFERER');
			
			// Continue loading the view data
			$info['data'] = $this->load->view('core/prompt',$prompt,TRUE);	// Systems
			$info['title'] = "Delete System \"".$sys->get_system_name()."\"";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	/**
	 * Renew a system registration for another year. This is to help remove dead registrations and keep the DB clean
     * @return void
     */
	public function renew() {
		// Get the current system object
		$sys = $this->impulselib->get_active_system();
		
		// Renew
		try {
			$this->api->systems->renew($sys);
			$this->_success("Successfully renewed \"".$sys->get_system_name()."\" for another year.");
		}
		catch (DBException $dbE) {
			$this->_error("DB:".$dbE->getMessage());
		}
		catch (ObjectException $oE) {
			$this->_error("Obj:".$oE->getMessage());
		}
	}

    /**
	 * Create a system from the given values. 
     * @return void
     */
	private function _create() {
		try {
			$sys = $this->api->systems->create->system(
				$this->input->post('systemName'),
				$this->impulselib->get_username(),
				$this->input->post('type'),
				$this->input->post('osName'),
				$this->input->post('comment')
			);
			
			if(!($sys instanceof System)) {
				throw new APIException("Could not instantate your system.");
			}
		}
		catch (DBException $dbE) {
			$this->_error("DB: ".$dbE->getMessage());
		}
		catch (ObjectException $oE) {
			$this->_error("Obj: ".$oE->getMessage());
		}	
		catch (APIException $apiE) {
			$this->_error("API: ".$apiE->getMessage());
		}
		
		return $sys;
	}

    /**
	 * Edit an existing system
     * @param $sys
     * @return void
     */
	private function _edit(&$sys) {
		
		// The error return message
		$err = "";
		
		// Check for which field was modified
		if($sys->get_system_name() != $this->input->post('systemName')) {
			try { $sys->set_system_name($this->input->post('systemName')); }
			catch (DBException $apiE) { $err .= $apiE->getMessage(); }
		}
		if($sys->get_type() != $this->input->post('type')) {
			try { $sys->set_type($this->input->post('type')); }
			catch (DBException $apiE) { $err .= $apiE->getMessage(); }
		}
		if($sys->get_os_name() != $this->input->post('osName')) {
			try { $sys->set_os_name($this->input->post('osName')); }
			catch (DBException $apiE) { $err .= $apiE->getMessage(); }
		}
		if($sys->get_comment() != $this->input->post('comment')) {
			try { $sys->set_comment($this->input->post('comment')); }
			catch (DBException $apiE) { $err .= $apiE->getMessage(); }
		}
		if($sys->get_owner() != $this->input->post('owner')) {
			try { $sys->set_owner($this->input->post('owner')); }
			catch (DBException $apiE) { $err .= $apiE->getMessage(); }
		}
		
		if($err != "") {
			$this->_error($err);
		}
	}

    /**
	 * Delete a system from the DB
     * @param $sys
     * @return int
     */
	private function _delete($sys) {
		try {
			$this->api->systems->remove->system($sys);
		}
		catch (DBException $dbE) {
			$this->_error("DB:".$dbE->getMessage());
		}
		catch (ObjectException $oE) {
			$this->_error("Obj:".$oE->getMessage());
		}
	}


}

/* End of file systems.php */
/* Location: ./application/controllers/systems.php */
