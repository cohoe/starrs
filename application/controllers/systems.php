<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Systems extends CI_Controller {
	
	public function index() {
	
		$this->owned();
	}

    public function all() {

		// Information
		
		$navModes['CREATE'] = "/systems/create/";
		$navOptions = array('Owned Systems'=>'/systems/owned','All Systems'=>'/systems/all');
		$navbar = new Navbar("All Systems", $navModes, $navOptions);
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

    public function owned() {

		// Information
		$navModes['CREATE'] = "/systems/create/";
		$navOptions = array('Owned Systems'=>'/systems/owned','All Systems'=>'/systems/all');
		$navbar = new Navbar("Owned Systems", $navModes, $navOptions);
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
			$sys = $this->api->systems->get_system_data($systemName,false);
			$systemViewData = $this->load->view('systems/system',array('system'=>$sys),TRUE);
			
			// Navbar information
			$navModes['EDIT'] = "/systems/edit/";
			$navModes['DELETE'] = "/systems/delete/";
			$navOptions = array('Overview'=>'overview','Interfaces'=>'interfaces');
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
					$navbar->set_create(TRUE,"/interfaces/create/");
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
			$this->impulselib->set_session('activeSystem',$sys);
		}
	}
	
	public function edit() {

		// Get the system object that we will be editing
		$sys = $this->impulselib->get_session('activeSystem');
		
		// Information is there
		if($this->input->post('submit')) {
			$this->_edit_system($sys);
		}
		
		// Need to input the information
		else {
			// Information
			$navModes['CANCEL'] = "";
			$navbar = new Navbar("Owned Systems", $navModes, null);
			#$navbar = new Navbar("Edit System - ".$sys->get_system_name(),FALSE,FALSE,TRUE,NULL,"/systems/edit/",array());
			
			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Get the preset form data for dropdown lists and things
			$form['operatingSystems'] = $this->api->systems->get_operating_systems();
			$form['systemTypes'] = $this->api->systems->get_system_types();
			$form['system'] = $sys;
			
			// Continue loading view data
			$info['data'] = $this->load->view('systems/edit',$form,TRUE);	// Systems
			$info['title'] = "Edit System";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
		
	}
	
	public function create() {
	
		// Information is there
		if($this->input->post('submit')) {
			$this->_create_system();
		}
		
		// Need to input the information
		else {
			// Information
            $navModes['CANCEL'] = "";
            $navbar = new Navbar("Create System", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Get the preset form data for dropdown lists and things
			$form['operatingSystems'] = $this->api->systems->get_operating_systems();
			$form['systemTypes'] = $this->api->systems->get_system_types();
			
			// Continue loading view data
			$info['data'] = $this->load->view('systems/create',$form,TRUE);	// Systems
			$info['title'] = "Create System";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	public function delete() {
		
		$sys = $this->impulselib->get_session('activeSystem');
		
		// They hit yes, delete the system
		if($this->input->post('yes')) {
			$code = $this->_delete_system($sys);
		}
		
		// They hit no, don't delete the system
		elseif($this->input->post('no')) {
			redirect($this->input->post('url'),'location');
		}
		
		// Need to print the prompt
		else {
			// Information
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
	
	private function _load_get_started() {

		// Information
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
	
	private function _load_interfaces($system) {
	
		// Get the interface objects for the system
		$interfaces = $this->api->systems->get_system_interfaces($system->get_system_name(),false);
		
		// Value of all interface view data
		$interfaceViewData = "";
		
		// Concatenate all view data into one string
		foreach ($interfaces as $interface) {
			$interfaceViewData .= $this->load->view('systems/interfaces',array('interface'=>$interface),TRUE);
		}
		
		// If there were no interfaces....
		if(count($interfaces) == 0) {
			$interfaceViewData = $this->load->view('systems/interfaces',array('none'=>true),TRUE);
		}

		// Spit back all of the interface data
		return $this->load->view('core/data',array('data'=>$interfaceViewData),TRUE);
	}
	
	private function _create_system() {
		#$this->api->management->deinitialize();
		#$this->api->management->initialize($this->impulselib->get_username());
		$this->api->systems->create_system(
			$this->input->post('systemName'),
			$this->impulselib->get_username(),
			$this->input->post('type'),
			$this->input->post('osName'),
			$this->input->post('comment')
		);
		#$this->api->management->deinitialize();
		redirect(base_url()."systems/view/".$this->input->post('systemName'),'location');
	}
	
	private function _edit_system($sys) {
	
		// SYS = old
		// POST = new
		
		if($sys->get_system_name() != $this->input->post('systemName')) {
			$sys->set_system_name($this->input->post('systemName'));
		}
		if($sys->get_type() != $this->input->post('type')) {
			$sys->set_type($this->input->post('type'));
		}
		if($sys->get_os_name() != $this->input->post('osName')) {
			$sys->set_os_name($this->input->post('osName'));
		}
		if($sys->get_comment() != $this->input->post('comment')) {
			$sys->set_comment($this->input->post('comment'));
		}
		
		redirect(base_url()."systems/view/".$this->input->post('systemName'),'location');
	}
	
	private function _delete_system($sys) {
		$query = $this->api->systems->remove_system($sys);
		if($query != "OK") {
			$this->_error($query);
			return 1;
		}
		else {
			redirect(base_url()."systems/",'location');
			return 0;
		}
	}
	
	private function _error($message) {
		// Information
        $navbar = new Navbar("Error", null, null);
		
		$data['message'] = $message;
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('core/error',$data,TRUE);
		$info['title'] = "Error";
		
		// Load the main view
		$this->load->view('core/main',$info);
	}	
}
