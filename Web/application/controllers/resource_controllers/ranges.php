<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Ranges extends ImpulseController {
	
	public static $ipRange;
	
	public function __construct() {
		parent::__construct();
	}
	
	public function index() {
		try {
			$ipRanges = $this->api->ip->get->ranges();
			$viewData = $this->load->view('resources/ranges/list',array("ipRanges"=>$ipRanges),TRUE);
		}
		catch (ObjectNotFoundException $onfE) {
			$viewData = $this->_warning("No ranges configured");
		}
		catch (Exception $e) {
			$this->_error($e->getMessage());
		}
		
		// Navbar
		$navModes = array();
		if($this->api->isadmin()) {
			$navModes['CREATE'] = "/resources/ranges/create/";
		}
		$navOptions['Resources'] = "/resources";
		$navbar = new Navbar("IP Ranges", $navModes, $navOptions);
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "IP Ranges";
        $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $viewData;

		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function view($range=NULL) {
		$range = urldecode($range);
		try {
			self::$ipRange = $this->api->ip->get->range($range);
		}
		catch (Exception $e) {
			$this->_error($e->getMessage());
		}
	
		// Navbar
		$navOptions['Ranges'] = "/resources/ranges/";
        $navOptions['DHCP Options'] = "/dhcp/options/view/range/".rawurlencode(self::$ipRange->get_name());
        $navOptions['Utilization'] = "/statistics/range_utilization/".rawurlencode(self::$ipRange->get_name());
		$navModes['EDIT'] = "/resources/ranges/edit/".rawurlencode(self::$ipRange->get_name());
		$navModes['DELETE'] = "/resources/ranges/delete/".rawurlencode(self::$ipRange->get_name());
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "Range - ".self::$ipRange->get_name();
		$navbar = new Navbar("Range - ".self::$ipRange->get_name(), $navModes, $navOptions);
		
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('resources/ranges/view',array("ipRange"=>self::$ipRange),TRUE);

		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function delete($range=NULL) {
		$range = urldecode($range);
		try {
			self::$ipRange = $this->api->ip->get->range($range);
		}
		catch (Exception $e) {
			$this->_error($e->getMessage());
		}
		
		// They hit yes, delete the subnet
		if($this->input->post('yes')) {
			try {
				$this->api->ip->remove->range($range);
				self::$sidebar->reload();
				redirect("resources/ranges",'location');
			}
			catch (Exception $e) {
				$this->_error($e->getMessage());
			}
		}
		
		// They hit no, don't delete the subnet
		elseif($this->input->post('no')) {
			redirect("resources/ranges/view/".rawurlencode($range),'location');
		}
		
		// Need to print the prompt
		else {
			// Navbar
            $navModes['CANCEL'] = "/resources/ranges/view/".rawurlencode($range);
			$navbar = new Navbar("Delete Range", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Load the prompt information
			$prompt['message'] = "Delete range \"$range\"?";
			$prompt['rejectUrl'] = $this->input->server('HTTP_REFERER');
			
			// Continue loading the view data
			$info['data'] = $this->load->view('core/prompt',$prompt,TRUE);	// Systems
			$info['title'] = "Delete Range - $range";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}

	public function create() {
		if($this->input->post('submit')) {
			$class = $this->input->post('class');
			if($class == "") {
				$class = null;
			}
			try {
				$ipRange = $this->api->ip->create->range(
					$this->input->post('name'),
					$this->input->post('first_ip'),
					$this->input->post('last_ip'),
					$this->input->post('subnet'),
					$this->input->post('use'),
					$class,
					$this->input->post('comment')
					
				);
				if(!($ipRange instanceof IpRange)) {
					$this->_error("Unable to instantiate range object");
				}
				self::$sidebar->reload();
				redirect("resources/ranges/view/".rawurlencode($ipRange->get_name()),'location');
			}
			catch (Exception $e) {
				$this->_error($e->getMessage());
			}
		}
		else {
            // Navbar
            $navModes['CANCEL'] = "/resources/ranges/";
            $navbar = new Navbar("Create Range", $navModes, null);
			
			// Load view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['title'] = "Create Range";
			
			// Form data
			try {
				$form['sNets'] = $this->api->ip->get->subnets(null);
				$form['uses'] = $this->api->ip->get->uses();
				$form['classes'] = $this->api->dhcp->get->classes();
			}
			catch (Exception $e) {
				$this->_error($e->getMessage());
			}
			
			// More view data
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $this->load->view("resources/ranges/create",$form,TRUE);

			// Load the main view
			$this->load->view('core/main',$info);
		}
	}

	public function edit($range=NULL) {
		$range = urldecode($range);
		try {
			self::$ipRange = $this->api->ip->get->range($range);
		}
		catch (Exception $e) {
			$this->_error($e->getMessage());
		}
				
		if($this->input->post('submit')) {
			$this->_edit();
			self::$sidebar->reload();
			redirect("resources/ranges/view/".rawurlencode(self::$ipRange->get_name()),'location');
		}
		else {
			// Navbar
			$navModes['CANCEL'] = "/resources/ranges/view/".rawurlencode(self::$ipRange->get_name());
			
			// Load view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['title'] = "Edit Range - ".self::$ipRange->get_name();
			$navbar = new Navbar("Edit Range - ".self::$ipRange->get_name(), $navModes, null);

			try {
				$form['sNets'] = $this->api->ip->get->subnets(null);
				$form['uses'] = $this->api->ip->get->uses();
				$form['classes'] = $this->api->dhcp->get->classes();
			}
			catch (Exception $e) {
				$this->_error($e->getMessage());
			}
			$form['ipRange'] = self::$ipRange;
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $this->load->view('resources/ranges/edit',$form,TRUE);

			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	private function _edit() {
		$err = "";
		if(self::$ipRange->get_name() != $this->input->post('name')) {
			try { self::$ipRange->set_name($this->input->post('name')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		if(self::$ipRange->get_first_ip() != $this->input->post('first_ip')) {
			try { self::$ipRange->set_first_ip($this->input->post('first_ip')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		if(self::$ipRange->get_last_ip() != $this->input->post('last_ip')) {
			try { self::$ipRange->set_last_ip($this->input->post('last_ip')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		if(self::$ipRange->get_subnet() != $this->input->post('subnet')) {
			try { self::$ipRange->set_subnet($this->input->post('subnet')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		if(self::$ipRange->get_use() != $this->input->post('use')) {
			try { self::$ipRange->set_use($this->input->post('use')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		if(self::$ipRange->get_class() != $this->input->post('class')) {
			$class = $this->input->post('class');
			if($this->input->post('class') == "") {
				$class=NULL;
			}
			try { self::$ipRange->set_class($class); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		if(self::$ipRange->get_comment() != $this->input->post('comment')) {
			try { self::$ipRange->set_comment($this->input->post('comment')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		
		if($err != "") {
			$this->_error($err);
		}
	}
}
/* End of file subnets.php */
/* Location: ./application/controllers/resource_controllers/subnets.php */
