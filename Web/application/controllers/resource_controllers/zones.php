<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Zones extends ImpulseController {
	
	public static $dnsZone;
	
	public function __construct() {
		parent::__construct();
	}
	
	public function index() {
		try {
			if($this->api->isadmin() ==  TRUE) {
				$dnsZones = $this->api->dns->get->zones(null);
			}
			else {
				$dnsZones = $this->api->dns->get->zones($this->api->get->current_user());
			}
		}
		catch (ObjectNotFoundException $onfE) {
			$viewData = $this->_warning("No DNS zones configured");
		}
		catch (DBException $dbE) {
			$this->_error($dbE->getMessage());
		}
		
		// Navbar
		$navModes['CREATE'] = "/resources/zones/create";
		$navOptions['Resources'] = "/resources";
		$navbar = new Navbar("DNS Zones", $navModes, $navOptions);
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "DNS Zones";

		$viewData = $this->load->view("resources/zones/list",array("dnsZones"=>$dnsZones),TRUE);
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $viewData;

		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function view($zone=NULL) {
		$zone = rawurldecode($zone);
		try {
			self::$dnsZone = $this->api->dns->get->zone($zone);
		}
		catch(Exception $e) {
			$this->_error("Unable to view zone \"$zone\": ".$e->getMessage());
		}
	
		// Navbar
		$navOptions['Zones'] = "/resources/zones/";
		
		$navModes['EDIT'] = "/resources/zones/edit/".urlencode(self::$dnsZone->get_zone());
		$navModes['DELETE'] = "/resources/zones/delete/".urlencode(self::$dnsZone->get_zone());
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "Zone - ".self::$dnsZone->get_zone();
		$navbar = new Navbar("Zone - ".self::$dnsZone->get_zone(), $navModes, $navOptions);
		
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('resources/zones/view',array("dnsZone"=>self::$dnsZone),TRUE);

		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function create() {
		if($this->input->post('submit')) {
			try {
				self::$dnsZone = $this->api->dns->create->zone(
					$this->input->post('zone'),
					$this->input->post('keyname'),
					$this->input->post('forward'),
					$this->input->post('shared'),
					$this->input->post('owner'),
					$this->input->post('comment')
				);
				if(!(self::$dnsZone instanceof DnsZone)) {
					$this->_error("Unable to instantiate DNS zone object");
				}
				self::$sidebar->reload();
				redirect(base_url()."resources/zones/view/".rawurlencode(self::$dnsZone->get_zone()),'location');
			}
			catch (Exception $e) {
				$this->_error($e->getMessage());
			}
		}
		else {
			// Navbar
			$navModes['CANCEL'] = "/resources/zones/";
			
			// Load view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['title'] = "Create DNS Zone";
			$navbar = new Navbar("Create DNS Zone", $navModes, null);
			$viewData['user'] = $this->api->get->current_user();
			$viewData['dnsKeys'] = $this->api->dns->get->keys($viewData['user']);
			if($this->api->isadmin() == TRUE) {
				$viewData['admin'] = TRUE;
			}
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $this->load->view('resources/zones/create',$viewData,TRUE);

			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	public function edit($zone=NULL) {
		$zone = rawurldecode($zone);
		if($zone == NULL) {
			$this->_error("No zone given for edit");
		}
		
		self::$dnsZone = $this->api->dns->get->zone($zone);
		
		if($this->input->post('submit')) {
			$this->_edit();
			self::$sidebar->reload();
			redirect(base_url()."resources/zones/view/".rawurlencode(self::$dnsZone->get_zone()));
		}
		else {
			// Navbar
			$navModes['CANCEL'] = "/resources/zones/view/".rawurlencode(self::$dnsZone->get_zone());
			
			// Load view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['title'] = "Edit Zone - ".self::$dnsZone->get_zone();
			$navbar = new Navbar("Edit Zone - ".self::$dnsZone->get_zone(), $navModes, null);
			$viewData['user'] = $this->api->get->current_user();
			$viewData['dnsKeys'] = $this->api->dns->get->keys($viewData['user']);
			$viewData['dnsZone'] = self::$dnsZone;
			if($this->api->isadmin() == TRUE) {
				$viewData['admin'] = TRUE;
			}
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $this->load->view('resources/zones/edit',$viewData,TRUE);

			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	public function delete($zone=NULL) {
		$zone = rawurldecode($zone);
		if($zone == NULL) {
			$this->_error("No zone given for delete");
		}
		
		// They hit yes, delete the zone
		if($this->input->post('yes')) {
			try {
				$this->api->dns->remove->zone($zone);
				self::$sidebar->reload();
				redirect(base_url()."resources/zones",'location');
			}
			catch (Exception $e) {
				$this->_error($e->getMessage());
			}
		}
		
		// They hit no, don't delete the system
		elseif($this->input->post('no')) {
			redirect(base_url()."resources/zones/view/".rawurlencode($zone),'location');
		}
		
		// Need to print the prompt
		else {
			// Navbar
            $navModes['CANCEL'] = "/resources/zones/view/".urlencode($zone);
			$navbar = new Navbar("Delete Zone", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Load the prompt information
			$prompt['message'] = "Delete zone \"$zone\" and all associated records?";
			$prompt['rejectUrl'] = $this->input->server('HTTP_REFERER');
			
			// Continue loading the view data
			$info['data'] = $this->load->view('core/prompt',$prompt,TRUE);	// Systems
			$info['title'] = "Delete Zone - $zone";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	private function _edit() {
		$err = "";
		if(self::$dnsZone->get_zone() != $this->input->post('zone')) {
			try { self::$dnsZone->set_zone($this->input->post('zone')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		if(self::$dnsZone->get_keyname() != $this->input->post('keyname')) {
			try { self::$dnsZone->set_keyname($this->input->post('keyname')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		if(self::$dnsZone->get_forward() != $this->input->post('forward')) {
			try { self::$dnsZone->set_forward($this->input->post('forward')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		if(self::$dnsZone->get_shared() != $this->input->post('shared')) {
			try { self::$dnsZone->set_shared($this->input->post('shared')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		if(self::$dnsZone->get_comment() != $this->input->post('comment')) {
			try { self::$dnsZone->set_comment($this->input->post('comment')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		if(self::$dnsZone->get_owner() != $this->input->post('owner')) {
			try { self::$dnsZone->set_owner($this->input->post('owner')); }
			catch (Exception $e) { $err .= $e->getMessage(); }
		}
		
		if($err != "") {
			$this->_error($err);
		}
	}
}
/* End of file zones.php */
/* Location: ./application/controllers/resource_controllers/zones.php */