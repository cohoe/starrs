<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "controllers/systems.php");

class Keys extends ImpulseController {
	
	public static $dnsKey;
	
	public function __construct() {
		parent::__construct();
	}
	
	public function index() {
		try {
			$dnsKeys = $this->api->dns->get_keys(null);
		}
		catch (ObjectNotFoundException $onfE) {
			$viewData = $this->_warning("No DNS keys configured");
		}
		catch (DBException $dbE) {
			$this->_error($dbE->getMessage());
		}
		
		// Navbar
		$navModes['CREATE'] = "/resources/keys/create/";
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['title'] = "DNS Keys";
		$navbar = new Navbar("DNS Keys", $navModes, null);

		$viewData = $this->load->view("resources/keys/list",array("dnsKeys"=>$dnsKeys),TRUE);
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $viewData;

		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function view($keyname=NULL) {
		$keyname = urldecode($keyname);
		$this->_load_key($keyname);
		
		if($this->api->isadmin() == FALSE && self::$dnsKey->get_owner() != $this->impulselib->get_username()) {
			$this->_error("Permission denied on key \"$keyname\". You are not owner or admin");
		}
	
		// Navbar
		$navOptions['Keys'] = "/resources/keys/";
		
		$navModes['EDIT'] = "/resources/keys/edit/".urlencode(self::$dnsKey->get_keyname());
		$navModes['DELETE'] = "/resources/keys/delete/".urlencode(self::$dnsKey->get_keyname());
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['title'] = "Key - ".self::$dnsKey->get_keyname();
		$navbar = new Navbar("Key - ".self::$dnsKey->get_keyname(), $navModes, $navOptions);
		
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('resources/keys/view',array("dnsKey"=>self::$dnsKey),TRUE);

		// Load the main view
		$this->load->view('core/main',$info);
	}

	public function create() {
		if($this->input->post('submit')) {
			try {
				$dnsKey = $this->api->dns->create->key(
					$this->input->post('name'),
					$this->input->post('key'),
					$this->input->post('owner'),
					$this->input->post('comment')
				);
				if(!($dnsKey instanceof DnsKey)) {
					$this->_error("Unable to instantiate DNS key object");
				}
				redirect("/resources/keys/view/".$dnsKey->get_keyname(),'location');
			}
			catch (Exception $e) {
				$this->_error($e->getMessage());
			}
		}
		else {
			// Load view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['title'] = "Create DNS Key";
			$navbar = new Navbar("Create DNS Key", null, null);
			
			// Form data
			$form['user'] = $this->impulselib->get_username();
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}
			
			// More view data
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $this->load->view("resources/keys/create",$form,TRUE);

			// Load the main view
			$this->load->view('core/main',$info);
		}
	}

	public function delete($keyname=NULL) {
		$keyname = urldecode($keyname);
		
		if($keyname == NULL) {
			$this->_error("No keyname was specified for delete");
		}
		
		try {
			$this->api->dns->remove->key($keyname);
			redirect(base_url()."resources/keys",'location');
		}
		catch (Exception $e) {
			$this->_error($e->getMessage());
		}
	}
	
	public function edit($keyname=NULL) {
		$keyname = urldecode($keyname);
		
		if($keyname == NULL) {
			$this->_error("No keyname was specified for edit");
		}
		
		$this->_load_key($keyname);
		
		if($this->input->post('submit')) {
			try {
				$dnsKey = $this->api->dns->create->key(
					$this->input->post('name'),
					$this->input->post('key'),
					$this->input->post('owner'),
					$this->input->post('comment')
				);
				if(!($dnsKey instanceof DnsKey)) {
					$this->_error("Unable to instantiate DNS key object");
				}
				redirect("/resources/keys/view/".$dnsKey->get_keyname(),'location');
			}
			catch (Exception $e) {
				$this->_error($e->getMessage());
			}
		}
		else {
			// Load view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['title'] = "Edit ".self::$dnsKey->get_keyname();
			$navbar = new Navbar("Edit ".self::$dnsKey->get_keyname(), null, null);
			
			// Form data
			$form['user'] = $this->impulselib->get_username();
			$form['dnsKey'] = self::$dnsKey;
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}
			
			// More view data
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $this->load->view("resources/keys/edit",$form,TRUE);

			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	private function _load_key($keyname) {
		try {
			self::$dnsKey = $this->api->dns->get_key($keyname);
		}
		catch (Exception $e) {
			$this->_error($e->getMessage());
		}
	}
	
}
/* End of file keys.php */
/* Location: ./application/controllers/keys.php */