<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Welcome extends ImpulseController {

	public function index() {
		$this->_success("Success");
		#$this->load->view('testing/sidebar');
	}

    private function _load_get_started() {

		// Information
		$navbar = new Navbar("Getting Started",FALSE,FALSE,NULL,"/systems",array("Create System"=>'create/system'));

		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('getstarted',"",TRUE);
		$info['title'] = "Getting Started";

		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	private function _load_demo() {
	
		$viewData = $this->load->view('core/success',array("message"=>"Success!"),TRUE);
		$viewData .= $this->load->view('core/warning',array("message"=>"Warning!"),TRUE);
		$viewData .= $this->load->view('core/error',array("message"=>"Error!"),TRUE);
		
		// Navbar
		$navbar = new Navbar("Demo", null, null);

		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $viewData;
		$info['title'] = "Demo";

		// Load the main view
		$this->load->view('core/main',$info);
	}
}

/* End of file welcome.php */
/* Location: ./application/controllers/welcome.php */
