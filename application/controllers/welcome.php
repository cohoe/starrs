<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Welcome extends CI_Controller {

	/**
	 * Index Page for this controller.
	 *
	 * Maps to the following URL
	 * 		http://example.com/index.php/welcome
	 *	- or -  
	 * 		http://example.com/index.php/welcome/index
	 *	- or -
	 * Since this controller is set as the default controller in 
	 * config/routes.php, it's displayed at http://example.com/
	 *
	 * So any other public methods not prefixed with an underscore will
	 * map to /index.php/welcome/<method_name>
	 * @see http://codeigniter.com/user_guide/general/urls.html
	 */
	public function index()
	{
		// Header
		$info['header'] = $this->load->view('mockup/header',"",TRUE);
		
		// Sidebar
		$info['sidebar'] = $this->load->view('mockup/sidebar',"",TRUE);
		
		// Information
		$navbarData['options'] = array('Create System','Create Interface','Assign IP Address');
		$navbarData['systemName'] = "Getting Started";
		$navbarData['edit'] = false;
		$info['navbar'] = $this->load->view('mockup/navbar',$navbarData,TRUE);
		$info['data'] = $this->load->view('mockup/getstarted',"",TRUE);
		
		// Load the main view
		$this->load->view('mockup/main',$info);
	}

    private function _load_get_started() {

		// Information
		$navbar = new Navbar("Getting Started",FALSE,FALSE,NULL,"/",array("Create System"));

		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('getstarted',"",TRUE);
		$info['title'] = "Getting Started";

		// Load the main view
		$this->load->view('mockup/main',$info);
	}
}

/* End of file welcome.php */
/* Location: ./application/controllers/welcome.php */
