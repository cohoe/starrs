<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Systems extends CI_Controller {
	
	public function index() {
	
		// Information
		$navOptions = array('Create System'=>'create/system');
		$navbar = new Navbar("All Systems",FALSE,FALSE,NULL,"/systems",$navOptions);
		$systemList = $this->api->get_systems(NULL);
		
		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('systems/systemlist',array('systems'=>$systemList),TRUE);
		$info['title'] = "Systems";
		
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
			$sys = $this->api->get_system_info($systemName,false);
			$systemViewData = $this->load->view('systems/system',array('system'=>$sys),TRUE);
			
			// Navbar information
			$navOptions = array('Overview'=>'overview','Interfaces'=>'interfaces');
			$navbar = new Navbar($sys->get_system_name(),TRUE,TRUE,$target,"/systems/view/".$sys->get_system_name(),$navOptions);
			
			// Check for network system
			// @todo: Make this legit and not half-assed
			if($sys->get_type() == 'Switch') {
				$navbar->add_option('Switchports','switchports');
			}
			
			// Figure out what page we are on and print accordingly
			switch(strtolower($target)) {
				case 'interfaces':
					$info['data'] = $this->_load_interfaces($sys);
					break;

				default:
					$info['data'] = $this->load->view('core/data',array('data'=>$systemViewData),TRUE);
					$navbar->set_active_page('Overview');
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
	
	public function edit($systemName=NULL) {

		// Get the system object that we will be editing
		$sys = $this->impulselib->get_session('activeSystem');
		
		// If a system name was not specified in the URL, get it from the activeSystem object
		if(!isset($systemName)) {
			$systemName = $sys->get_system_name();
		}
		
		// Edit the system
		echo "Editing system ".$sys->get_system_name();
	}
	
	public function create() {
	
		// Information is there
		if($this->input->post('submit')) {
			$this->_create_system();
		}
		
		// Need to input the information
		else {
			// Information
			$navbar = new Navbar("Create System",FALSE,FALSE,NULL,"/systems/create/system",array());
			
			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Get the preset form data for dropdown lists and things
			$form['operatingSystems'] = $this->api->get_operating_systems();
			$form['systemTypes'] = $this->api->get_system_types();
			
			// Continue loading view data
			$info['data'] = $this->load->view('systems/create',$form,TRUE);	// Systems
			$info['title'] = "Create System";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	public function delete($systemName) {
		
		// They hit yes, delete the system
		if($this->input->post('yes')) {
			$this->_delete_system($systemName);
		}
		
		// They hit no, don't delete the system
		elseif($this->input->post('no')) {
			redirect($this->input->post('url'),'location');
		}
		
		// Need to print the prompt
		else {
			// Information
			$navbar = new Navbar("Delete System",FALSE,FALSE,NULL,"/systems/delete",array());

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Load the prompt information
			$prompt['message'] = "Delete system \"$systemName\"?";
			$prompt['rejectUrl'] = $this->input->server('HTTP_REFERER');
			
			// Continue loading the view data
			$info['data'] = $this->load->view('core/prompt',$prompt,TRUE);	// Systems
			$info['title'] = "Delete System \"$systemName\"";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	private function _load_get_started() {

		// Information
		$navbar = new Navbar("Getting Started",FALSE,FALSE,NULL,"systems/",array("Create System"));
		
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
		$interfaces = $this->api->get_system_interfaces($system->get_system_name(),false);
		
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
		$this->api->deinitialize();
		$this->api->initialize($this->impulselib->get_username());
		$this->api->create_system(
			$this->input->post('systemName'),
			$this->impulselib->get_username(),
			$this->input->post('type'),
			$this->input->post('osName'),
			$this->input->post('comment')
		);
		$this->api->deinitialize();
		redirect(base_url()."systems/view/".$this->input->post('systemName'),'location');
	}
	
	private function _delete_system($systemName) {
		$this->api->deinitialize();
		$this->api->initialize($this->impulselib->get_username());
		$this->api->remove_system($systemName);
		$this->api->deinitialize();
		redirect(base_url()."systems/",'location');
	}
	
	public function chart() {
		#$data = $this->api->get_os_distribution();
		#$this->load->view('systems/os_distribution',array("data"=>$data));
		echo $this->impulselib->get_name_string();
	}
	
}
