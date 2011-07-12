<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Welcome extends CI_Controller {

	public function index()
	{
		$this->_load_get_started();
	}

    private function _load_get_started() {

		// Information
		$navbar = new Navbar("Getting Started",FALSE,FALSE,NULL,"/systems",array("Create System"=>'create/system'));

		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('getstarted',"",TRUE);
		$info['title'] = "Getting Started";

		// Load the main view
		$this->load->view('core/main',$info);
	}
}

/* End of file welcome.php */
/* Location: ./application/controllers/welcome.php */
