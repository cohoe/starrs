<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Systems extends CI_Controller {
	
	public function index() {
		// CSS
		echo link_tag("css/mockup/main.css");
		echo link_tag("css/mockup/impulse.css");
	
		// Header
		$info['header'] = $this->load->view('mockup/header',"",TRUE);
		
		// Sidebar
		$info['sidebar'] = $this->load->view('mockup/sidebar',"",TRUE);
		
		// Information
		$navbarData['options'] = array('Create System','Create Interface','Assign IP Address');
		$navbarData['title'] = "All Systems";
		$navbarData['edit'] = false;
		$info['navbar'] = $this->load->view('mockup/navbar',$navbarData,TRUE);
		
		// Systems
		$systemList = $this->api->get_systems(NULL);
		$info['data'] = $this->load->view('mockup/systemlist',array('systems'=>$systemList),TRUE);
		
		// Load the main view
		$this->load->view('mockup/main',$info);
	}
	
	public function view($systemName=NULL) {
		// CSS
		echo link_tag("css/mockup/main.css");
		echo link_tag("css/mockup/impulse.css");
		
		if(!isset($systemName)) {
			// Header
			$info['header'] = $this->load->view('mockup/header',"",TRUE);
			
			// Sidebar
			$info['sidebar'] = $this->load->view('mockup/sidebar',"",TRUE);
			
			// Information
			$navbarData['options'] = array('Create System','Create Interface','Assign IP Address');
			$navbarData['title'] = "Getting Started";
			$navbarData['edit'] = false;
			$info['navbar'] = $this->load->view('mockup/navbar',$navbarData,TRUE);
			$info['data'] = $this->load->view('mockup/getstarted',"",TRUE);
			
			// Load the main view
			$this->load->view('mockup/main',$info);
		}
		else {
			// System Object
			$sys = $this->api->get_system_info($systemName,false);
			$systemViewData = $this->load->view('mockup/system',array('system'=>$sys),TRUE);
			
			// Header
			$info['header'] = $this->load->view('mockup/header',"",TRUE);
			
			// Sidebar
			$info['sidebar'] = $this->load->view('mockup/sidebar',"",TRUE);
			
			// Information
			$navbarData['options'] = array('Overview','Interfaces','Addresses','Firewall Rules');
			$navbarData['title'] = $sys->get_system_name();
			$navbarData['edit'] = true;
			$info['navbar'] = $this->load->view('mockup/navbar',$navbarData,TRUE);
			$info['data'] = $this->load->view('mockup/data',array('data'=>$systemViewData),TRUE);
			
			// Load the main view
			$this->load->view('mockup/main',$info);
			
			session_start();
			$_SESSION['system'] = $sys;
		}	
	}
	
	public function edit($systemName=NULL) {
		session_start();
		$sys = $_SESSION['system'];
		
		if(!isset($systemName)) {
			$systemName = $sys->get_system_name();
			redirect(base_url()."mockup/edit/$systemName",'location');
		}
		
		echo "Editing system ".$sys->get_system_name();
		#print_r($_SESSION);
	}
}