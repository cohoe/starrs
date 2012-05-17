<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Systems extends ImpulseController {
	
    /**
	 * If no additional URL paramters were specified, load this default view
     * @return void
     */
	public function index() {
		$this->_error("What would you like to do today dirtbag?");
	}
	
	public function view($mode=NULL) {
		switch($mode) {
			case "all":
				$this->_all();
				break;
			default:
				$this->_owned();
				break;
		}
	}

    /**
	 * View all of the systems registered in the IMPULSE database
     * @return void
     */
    private function _all() {
		// List of systems
		try {
			$systemList = $this->api->systems->get->systems(NULL);
			$viewData = $this->load->view('systems/systemlist',array('systems'=>$systemList),TRUE);
		}
		catch (ObjectNotFoundException $onfE) {
			$viewData = $this->_warning("No systems found!");
		}
		
		// Navbar
		$navModes['CREATE'] = "/system/create";
		$navbar = new Navbar("Systems - All", $navModes, null);

		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $viewData;
		$info['title'] = "Systems - All";

		// Load the main view
		$this->load->view('core/main',$info);
	}

    /**
	 * View all of the systems that you are the owner for in the IMPULSE database
     * @return void
     */
    private function _owned() {
		// List of systems
		try {
			$systemList = $this->api->systems->get->systems($this->impulselib->get_username());
			$viewData = $this->load->view('systems/systemlist',array('systems'=>$systemList),TRUE);
		}
		catch (ObjectNotFoundException $onfE) {
			$viewData = $this->_warning("No systems found!");
		}
		
		// Navbar
		$navModes['CREATE'] = "/system/create";
		$navbar = new Navbar("Systems - Owned", $navModes, null);

		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $viewData;
		$info['title'] = "Systems - Owned";
		$info['help'] = $this->load->view("help/systems/owned",null,TRUE);
		
		// Load the main view
		$this->load->view('core/main',$info);
	}
}
/* End of file systems.php */
/* Location: ./application/controllers/systems.php */