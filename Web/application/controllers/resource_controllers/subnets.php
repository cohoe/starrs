<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Subnets extends ImpulseController {
	
	public static $sNet;
	
	public function __construct() {
		parent::__construct();
	}
	
	public function index() {
		redirect("resources/subnets/owned",'location');
	}
	
	public function owned() {
		try {
			$sNets = $this->api->ip->get->subnets($this->api->get->current_user());
			$viewData = $this->load->view("resources/subnets/list",array("sNets"=>$sNets),TRUE);
		}
		catch (ObjectNotFoundException $onfE) {
			$viewData = $this->_warning("No subnets configured!");
		}
		
		// Navbar
		$navOptions['Resources'] = "/resources";
		$navOptions['Owned'] = "/resources/subnets/owned";
		$navOptions['All'] = "/resources/subnets/all";
		$navModes['CREATE'] = "/resources/subnets/create";
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "Subnets";
		$navbar = new Navbar("Subnets", $navModes, $navOptions);

		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $viewData;

		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function all() {
		try {
			$sNets = $this->api->ip->get->subnets(null);
			$viewData = $this->load->view("resources/subnets/list",array("sNets"=>$sNets),TRUE);
		}
		catch (ObjectNotFoundException $onfE) {
			$viewData = $this->_warning("No subnets configured!");
		}
		
		// Navbar
		$navOptions['Resources'] = "/resources";
		$navOptions['Owned'] = "/resources/subnets/owned";
		$navOptions['All'] = "/resources/subnets/all";
		$navModes['CREATE'] = "/resources/subnets/create";
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "Subnets";
		$navbar = new Navbar("Subnets", $navModes, $navOptions);

		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $viewData;

		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function view($subnet=NULL) {
		$subnet = urldecode($subnet);
		self::$sNet = $this->api->ip->get->subnet($subnet);
	
		// Navbar
		$navOptions['Subnets'] = "/resources/subnets/";
        $navOptions['DHCP Options'] = "/dhcp/options/view/subnet/".rawurlencode(self::$sNet->get_subnet());
        $navOptions['Utilization'] = "/statistics/subnet_utilization/".rawurlencode(self::$sNet->get_subnet());
		$navModes['EDIT'] = "/resources/subnets/edit/".rawurlencode(self::$sNet->get_subnet());
		$navModes['DELETE'] = "/resources/subnets/delete/".rawurlencode(self::$sNet->get_subnet());
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "Subnet - ".self::$sNet->get_subnet();
		$navbar = new Navbar("Subnet - ".self::$sNet->get_subnet(), $navModes, $navOptions);
		
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('resources/subnets/view',array("sNet"=>self::$sNet),TRUE);

		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function delete($subnet=NULL) {
		$subnet = urldecode($subnet);
		if($subnet == NULL) {
			$subnet->_error("No subnet given for delete");
		}
		
		// They hit yes, delete the subnet
		if($this->input->post('yes')) {
			try {
				$this->api->ip->remove->subnet($subnet);
				self::$sidebar->reload();
				redirect("resources/subnets/owned",'location');
			}
			catch (Exception $e) {
				$this->_error($e->getMessage());
			}
		}
		
		// They hit no, don't delete the subnet
		elseif($this->input->post('no')) {
			redirect("resources/subnets/view/".urlencode($subnet),'location');
		}
		
		// Need to print the prompt
		else {
			// Navbar
            $navModes['CANCEL'] = "/resources/subnets/view/".urlencode($subnet);
			$navbar = new Navbar("Delete Subnet", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Load the prompt information
			$prompt['message'] = "Delete subnet \"$subnet\" and all associated objects?";
			$prompt['rejectUrl'] = $this->input->server('HTTP_REFERER');
			
			// Continue loading the view data
			$info['data'] = $this->load->view('core/prompt',$prompt,TRUE);	// Systems
			$info['title'] = "Delete Subnet - $subnet";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}

	public function create() {
		if($this->input->post('submit')) {
			try {
				$sNet = $this->api->ip->create->subnet(
					$this->input->post('subnet'),
					$this->input->post('name'),
					$this->input->post('comment'),
					$this->input->post('autogen'),
					$this->input->post('dhcp'),
					$this->input->post('zone'),
					$this->input->post('owner')
					
				);
				if(!($sNet instanceof Subnet)) {
					$this->_error("Unable to instantiate subnet object");
				}
				self::$sidebar->reload();
				redirect("resources/subnets/view/".urlencode($sNet->get_subnet()),'location');
			}
			catch (Exception $e) {
				$this->_error($e->getMessage());
			}
		}
		else {
            // Navbar
            $navModes['CANCEL'] = "/resources/subnets/";
            
			// Load view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['title'] = "Create Subnet";
			$navbar = new Navbar("Create Subnet", $navModes, null);
			
			// Form data
			$form['user'] = $this->impulselib->get_username();
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
				$form['dnsZones'] = $this->api->dns->get->zones(null);
			}
			else {
				$form['dnsZones'] = $this->api->dns->get->zones($this->api->get->current_user());
			}
			
			// More view data
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $this->load->view("resources/subnets/create",$form,TRUE);

			// Load the main view
			$this->load->view('core/main',$info);
		}
	}

	public function edit($subnet=NULL) {
		$subnet = urldecode($subnet);
		if($subnet == NULL) {
			$this->_error("No subnet given for edit");
		}
		
		self::$sNet = $this->api->ip->get->subnet($subnet);
		
		if($this->input->post('submit')) {
			$this->_edit();
			self::$sidebar->reload();
			redirect("resources/subnets/view/".urlencode(self::$sNet->get_subnet()),'location');
		}
		else {
			// Navbar
			$navModes['CANCEL'] = "/resources/subnets/view/".urlencode(self::$sNet->get_subnet());
			
			// Load view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['title'] = "Edit Subnet - ".self::$sNet->get_subnet();
			$navbar = new Navbar("Edit Subnet - ".self::$sNet->get_subnet(), $navModes, null);
			if($this->api->isadmin() == TRUE) {
				$viewData['admin'] = TRUE;
				$viewData['dnsZones'] = $this->api->dns->get->zones(null);
			}
			else {
				$viewData['dnsZones'] = $this->api->dns->get->zones($this->api->get->current_user());
			}
			$viewData['sNet'] = self::$sNet;
			if($this->api->isadmin() == TRUE) {
				$viewData['admin'] = TRUE;
			}
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $this->load->view('resources/subnets/edit',$viewData,TRUE);

			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	private function _edit() {
		$err = "";
		if(self::$sNet->get_subnet() != $this->input->post('subnet')) {
			try { self::$sNet->set_subnet($this->input->post('subnet')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		if(self::$sNet->get_name() != $this->input->post('name')) {
			try { self::$sNet->set_name($this->input->post('name')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		if(self::$sNet->get_comment() != $this->input->post('comment')) {
			try { self::$sNet->set_comment($this->input->post('comment')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		if(self::$sNet->get_autogen() != $this->input->post('autogen')) {
			try { self::$sNet->set_autogen($this->input->post('autogen')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		if(self::$sNet->get_zone() != $this->input->post('zone')) {
			try { self::$sNet->set_zone($this->input->post('zone')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		if(self::$sNet->get_dhcp_enable() != $this->input->post('dhcp')) {
			try { self::$sNet->set_dhcp_enable($this->input->post('dhcp')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		if(self::$sNet->get_owner() != $this->input->post('owner')) {
			try { self::$sNet->set_owner($this->input->post('owner')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		
		if($err != "") {
			$this->_error($err);
		}
	}
}
/* End of file subnets.php */
/* Location: ./application/controllers/resource_controllers/subnets.php */