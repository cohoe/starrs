<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/controller.php");

/**
 * This controller handles all information regarding the system objects. You can create, edit, and delete systems
 * that you have permission to do so on. 
 */
class Systems extends IMPULSE_Controller {

    /**
	 * If no additional URL paramters were specified, load this default view
     * @return void
     */
	public function index() {
	
		$this->owned();
	}

    /**
	 * View all of the systems registered in the IMPULSE database
     * @return void
     */
    public function all() {

		// Navbar
		$navModes['CREATE'] = "/systems/create/";
		$navOptions = array('Owned Systems'=>'/systems/owned','All Systems'=>'/systems/all');
		$navbar = new Navbar("All Systems", $navModes, $navOptions);
		
		// List of systems
		$systemList = $this->api->systems->get_systems(NULL);

		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('systems/systemlist',array('systems'=>$systemList),TRUE);
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
		$navModes['CREATE'] = "/systems/create/";
		$navOptions = array('Owned Systems'=>'/systems/owned','All Systems'=>'/systems/all');
		$navbar = new Navbar("Owned Systems", $navModes, $navOptions);
		
		// List of systems
		$systemList = $this->api->systems->get_systems($this->impulselib->get_username());

		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('systems/systemlist',array('systems'=>$systemList),TRUE);
		$info['title'] = "Owned Systems";

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
	
		// Clean up the URL data since it will have %20's rather than spaces
		$systemName = $this->impulselib->remove_url_space($systemName);
		$target = $this->impulselib->remove_url_space($target);
		
		// If no system was specified, then go to the get started page. 
		if($systemName == NULL) {
			$this->_load_get_started();
		}
		
		// We got a system, deal with it
		else {
			// If no target was specififed, go to the overview page
			if($target == NULL) {
				$target = "overview";
			}
			
			// System Object
			try {
				$sys = $this->api->systems->get_system_data($systemName,false);
			}
			catch (ObjectNotFoundException $oNFE) {
				$this->_error("System not found!");
				return null;
			}
			$systemViewData = $this->load->view('systems/system',array('system'=>$sys),TRUE);
			
			// Navbar information
			$navModes = array();
			$navOptions['Overview'] = "/systems/view/".$sys->get_system_name()."/overview";
			$navOptions['Interfaces'] = "/systems/view/".$sys->get_system_name()."/interfaces";
			
			if($this->api->get_editable($sys) == true) {
				$navOptions['Renew'] = "/systems/renew/".$sys->get_system_name();
				$navModes['EDIT'] = "/systems/edit/";
				$navModes['DELETE'] = "/systems/delete/";
			}
			$navbar = new Navbar($sys->get_system_name(), $navModes, $navOptions);
			
			// Check for network system
			// @todo: Make this legit and not half-assed
			if($sys->get_type() == 'Switch') {
				$navbar->add_option('Switchports','switchports');
			}
			
			// Figure out what page we are on and print accordingly
			switch(strtolower($target)) {
				case 'interfaces':
					$info['data'] = $this->_load_interfaces($sys);
					if($this->api->get_editable($sys) == true) {
						$navbar->set_create(TRUE,"/interfaces/create/".$sys->get_system_name());
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
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['title'] = "System - ".$sys->get_system_name();
			
			// Load the main view
			$this->load->view('core/main',$info);
			
			// Set the active system object to prepare for changes
			#$this->impulselib->set_session('activeSystem',$sys);
			$_SESSION['activeSystem'] = $sys;
		}
	}

    /**
	 * Edit the properties of an existing system
     * @return void
     */
	public function edit() {

		// Get the system object that we will be editing
		$sys = $this->impulselib->get_session('activeSystem');
		
		// Information is there. Execute the edit
		if($this->input->post('submit')) {
			$this->_edit_system($sys);
		}
		
		// Need to input the information
		else {
			// Navbar
			$navModes['CANCEL'] = "";
			$navbar = new Navbar("Edit System", $navModes, null);
			
			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Get the preset form data for dropdown lists and things
			$form['operatingSystems'] = $this->api->systems->get_operating_systems();
			$form['systemTypes'] = $this->api->systems->get_system_types();
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
	}

    /**
	 * Create a new system in the database
     * @return void
     */
	public function create() {
	
		// Information is there. Create the system
		if($this->input->post('submit')) {
			$this->_create_system();
		}
		
		// Need to input the information
		else {
			// Navbar
            $navModes['CANCEL'] = "";
            $navbar = new Navbar("Create System", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Get the preset form data for dropdown lists and things
			$form['operatingSystems'] = $this->api->systems->get_operating_systems();
			$form['systemTypes'] = $this->api->systems->get_system_types();
			$form['user'] = $this->impulselib->get_username();
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
		$sys = $this->impulselib->get_session('activeSystem');
		
		// They hit yes, delete the system
		if($this->input->post('yes')) {
			$this->_delete_system($sys);
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
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
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
		$sys = $this->impulselib->get_session('activeSystem');
		
		// Renew
		$query = $this->api->systems->renew($sys);
		
		// View
		if($query != "OK") {
			$this->_error($query);
		}
		else {
			$this->success("Successfully renewed system for another year.");
		}
	}

    /**
	 * This will open the getting started view to point users in the right direction
     * @return void
     */
	private function _load_get_started() {

		// Navbar
        $navOptions = array('Create System'=>'/systems/create');
        $navbar = new Navbar("Getting Started", null, $navOptions);
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('systems/getstarted',"",TRUE);
		$info['title'] = "Getting Started";
		
		// Load the main view
		$this->load->view('mockup/main',$info);
	}

    /**
	 * Prepare a list of all interfaces attached to a system. 
     * @param $system
     * @return
     */
	private function _load_interfaces($system) {
	
		// Get the interface objects for the system
		$interfaces = $this->api->systems->get_system_interfaces($system->get_system_name(),false);
		
		// Value of all interface view data
		$interfaceViewData = "";
		
		// Start the session
		session_start();
		
		// Concatenate all view data into one string
		foreach ($interfaces as $interface) {
			
			// Navbar
			$navModes = array();
			if($this->api->get_editable($interface) == true) {
				$navModes['EDIT'] = "/interfaces/edit/".$interface->get_mac();
				$navModes['DELETE'] = "/interfaces/delete/".$interface->get_mac();
			}
			$navOptions['Addresses'] = "/interfaces/addresses/".$interface->get_mac();
			$navbar = new Navbar("Interface", $navModes, $navOptions);
		
			$interfaceViewData .= $this->load->view('systems/interfaces',array('interface'=>$interface, 'navbar'=>$navbar),TRUE);
			
			$_SESSION['interfaces'][$interface->get_mac()] = $interface;
		}
		
		// If there were no interfaces....
		if(count($interfaces) == 0) {
		
			$navbar = new Navbar("Interface", null, null);
			$interfaceViewData = $this->load->view('core/warning',array("message"=>"No interfaces found!"),TRUE);
		}

		// Spit back all of the interface data
		return $this->load->view('core/data',array('data'=>$interfaceViewData),TRUE);
	}

    /**
	 * Create a system from the given values. 
     * @return void
     */
	private function _create_system() {
		$query = $this->api->systems->create_system(
			$this->input->post('systemName'),
			$this->impulselib->get_username(),
			$this->input->post('type'),
			$this->input->post('osName'),
			$this->input->post('comment')
		);
		
		if($query != "OK") {
			$this->_error($query);
		}
		else {
			redirect(base_url()."systems/view/".$this->input->post('systemName'),'location');
		}		
	}

    /**
	 * Edit an existing system
     * @param $sys
     * @return void
     */
	private function _edit_system($sys) {
		
		// The error return message
		$err = "";
		
		// Check for which field was modified
		if($sys->get_system_name() != $this->input->post('systemName')) {
			try { $sys->set_system_name($this->input->post('systemName')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if($sys->get_type() != $this->input->post('type')) {
			try { $sys->set_type($this->input->post('type')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if($sys->get_os_name() != $this->input->post('osName')) {
			try { $sys->set_os_name($this->input->post('osName')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if($sys->get_comment() != $this->input->post('comment')) {
			try { $sys->set_comment($this->input->post('comment')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if($sys->get_owner() != $this->input->post('owner')) {
			try { $sys->set_owner($this->input->post('owner')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		
		if($err != "") {
			$this->_error($err);
		}
		else {
			redirect(base_url()."systems/view/".$this->input->post('systemName'),'location');
		}
	}

    /**
	 * Delete a system from the DB
     * @param $sys
     * @return int
     */
	private function _delete_system($sys) {
		$query = $this->api->systems->remove_system($sys);
		if($query != "OK") {
			$this->_error($query);
		}
		else {
			redirect(base_url()."systems/",'location');
		}
	}
	
	
}
