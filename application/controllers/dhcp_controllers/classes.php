<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Classes extends ImpulseController {
	
	public static $class;
	
	public function __construct() {
		parent::__construct();
	}
	
	public function index() {
		try {
			$classes = $this->api->dhcp->get->classes();
			$viewData = $this->load->view('dhcp/classes/list',array("classes"=>$classes),TRUE);
		}
		catch (ObjectNotFoundException $onfE) {
			$viewData = $this->_warning("No classes configured");
		}
		catch (Exception $e) {
			$this->_error($e->getMessage());
		}
	
		// Navbar
		$navModes = array();
		if($this->api->isadmin()) {
			$navModes['CREATE'] = "/dhcp/classes/create/";
		}
		$navOptions['DHCP'] = "/dhcp";
		$navbar = new Navbar("DHCP Classes", $navModes, $navOptions);
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "DHCP Classes";
        $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $viewData;

		// Load the main view
		$this->load->view('core/main',$info);
	}

    public function view($class=NULL) {
        if($class==NULL) {
            $this->_error("No class specified for view");
        }
        $class = urldecode($class);
		try {
			self::$class = $this->api->dhcp->get->_class($class);
			$viewData = $this->load->view('dhcp/classes/view',array("class"=>self::$class),TRUE);
		}
		catch (ObjectNotFoundException $onfE) {
			$viewData = $this->_error("Could not find a class named \"{$class}\".");
		}
		catch (Exception $e) {
			$this->_error($e->getMessage());
		}

        // Navbar
		$navOptions['All'] = "/dhcp/classes/";
		$navOptions['DHCP Options'] = "/dhcp/options/view/class/{$class}";
		$navModes = array();
		if($this->api->isadmin()) {
			$navModes['EDIT'] = "/dhcp/classes/edit/{$class}";
			$navModes['DELETE'] = "/dhcp/classes/delete/{$class}";
		}
		$navbar = new Navbar("DHCP Class - ".ucfirst($class), $navModes, $navOptions);
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "DHCP Class - ".ucfirst($class);
        $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $viewData;

		// Load the main view
		$this->load->view('core/main',$info);
    }

	public function create() {
		if($this->input->post('submit')) {
			try {
				self::$class = $this->api->dhcp->create->_class($this->input->post('class'),$this->input->post('comment'));
				self::$sidebar->reload();
				redirect(base_url()."dhcp/classes/view/".rawurlencode(self::$class->get_class()),'location');
			}
			catch (ObjectNotFoundException $onfE) {
				$this->_error("API didn't return your class.");
			}
			catch (Exception $e) {
				$this->_error($e->getMessage());
			}
		}
		else {
			// Navbar
			$navModes['CANCEL'] = "/dhcp/classes/";
			$navbar = new Navbar("Create DHCP Class", $navModes, null);

			// Load view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['title'] = "Create DHCP Class";
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $this->load->view('dhcp/classes/create',null,TRUE);

			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	public function delete($class=NULL) {
		$class = rawurldecode($class);
		if($class == NULL) {
			$this->_error("No class given for delete");
		}
		
		// They hit yes, delete the class
		if($this->input->post('yes')) {
			try {
				$this->api->dhcp->remove->_class($class);
				self::$sidebar->reload();
				redirect(base_url()."dhcp/classes",'location');
			}
			catch (Exception $e) {
				$this->_error($e->getMessage());
			}
		}
		
		// They hit no, don't delete the class
		elseif($this->input->post('no')) {
			redirect(base_url()."dhcp/classes/view/".rawurlencode($class),'location');
		}
		
		// Need to print the prompt
		else {
			// Navbar
            $navModes['CANCEL'] = "/dhcp/classes/view/".rawurlencode($class);
			$navbar = new Navbar("Delete Class", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Load the prompt information
			$prompt['message'] = "Delete class \"{$class}\" and all associated objects?";
			$prompt['rejectUrl'] = $this->input->server('HTTP_REFERER');
			
			// Continue loading the view data
			$info['data'] = $this->load->view('core/prompt',$prompt,TRUE);	// Systems
			$info['title'] = "Delete Class - {$class}";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}

	public function edit($class=NULL) {
		$class = rawurldecode($class);
		if($class == NULL) {
			$this->_error("No class given for delete");
		}
		
		try {
			self::$class = $this->api->dhcp->get->_class($class);
		}
		catch (Exception $e) {
			$this->_error($e->getMessage());
		}
		
		if($this->input->post('submit')) {
			$err = "";
			
			if(self::$class->get_class() != $this->input->post('class')) {
				try { self::$class->set_class($this->input->post('class')); }
				catch (Exception $e) { $err .= $e->getMessage(); }
			}
			if(self::$class->get_comment() != $this->input->post('comment')) {
				try { self::$class->set_comment($this->input->post('comment')); }
				catch (Exception $e) { $err .= $e->getMessage(); }
			}
			
			if($err != "") {
				$this->_error($err);
			}
			else {
				self::$sidebar->reload();
				redirect(base_url()."dhcp/classes/view/".rawurlencode($class),'location');
			}
		}
		else {
			// Navbar
			$navModes['CANCEL'] = "/dhcp/classes/view/{$class}";
			$navbar = new Navbar("Edit Class ".ucfirst($class), $navModes, null);

			// Load view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['title'] = "Edit Class ".ucfirst($class);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			$form['class'] = self::$class;
			$info['data'] = $this->load->view('dhcp/classes/edit',$form,TRUE);

			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
}
/* End of file classes.php */
/* Location: ./application/controllers/dhcp_controllers/classes.php */