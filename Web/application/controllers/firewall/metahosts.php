<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Metahosts extends ImpulseController {

	public function index() {
		$this->owned();
	}

	public function owned() {
		// Navbar
		$navModes['CREATE'] = "/firewall/metahosts/create/";
		$navOptions['Owned Metahosts'] = '/firewall/metahosts/owned';
		$navOptions['All Metahosts'] = '/firewall/metahosts/all';
		$navbar = new Navbar("Owned Metahosts", $navModes, $navOptions);
		
		try {
			$mhostList = $this->api->firewall->get->metahosts($this->impulselib->get_username());
			$viewData = $this->load->view('metahosts/list',array('mhosts'=>$mhostList),TRUE);
		}
		catch (ObjectNotFoundException $onfE) {
			$viewData = $this->_warning("No metahosts found!");
		}

		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $viewData;
		$info['title'] = "Owned Metahosts";
		
		// Load the main view
		$this->load->view('core/main',$info);
	}

	public function all() {
		// Navbar
		$navModes['CREATE'] = "/firewall/metahosts/create/";
		$navOptions['Owned Metahosts'] = '/firewall/metahosts/owned';
		$navOptions['All Metahosts'] = '/firewall/metahosts/all';
		$navbar = new Navbar("Owned Metahosts", $navModes, $navOptions);
		
		try {
			$mhostList = $this->api->firewall->get->metahosts(null);
			$viewData = $this->load->view('metahosts/list',array('mhosts'=>$mhostList),TRUE);
		}
		catch (ObjectNotFoundException $onfE) {
			$viewData = $this->_warning("No metahosts found!");
		}

		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $viewData;
		$info['title'] = "Owned Metahosts";
		
		// Load the main view
		$this->load->view('core/main',$info);
	}

	public function view($metahostName=NULL) {
		if($metahostName == NULL) {
			$this->_error("No metahost specified");
		}
		$metahostName = rawurldecode($metahostName);
		try {
			self::$mHost = $this->api->firewall->get->metahost($metahostName,false);
		}
		catch (DBException $dbE) {
			$this->_error($dbE->getMessage());
		}
		catch (AmbiguousTargetException $atE) {
			$this->_error($atE->getMessage());
		}
		catch (ObjectNotFoundException $onfE) {
			$this->_error($onfE->getMessage());
		}
		
		// Navbar
		$navModes['EDIT'] = "/firewall/metahosts/edit/".rawurlencode(self::$mHost->get_name());
		$navModes['DELETE'] = "/firewall/metahosts/delete/".rawurlencode(self::$mHost->get_name());
		$navOptions['Overview'] = '/firewall/metahosts/view/'.rawurlencode(self::$mHost->get_name());
		$navOptions['Members'] = '/firewall/metahost_members/view/'.rawurlencode(self::$mHost->get_name());
		$navOptions['Rules'] = '/firewall/metahosts/rules/view/'.rawurlencode(self::$mHost->get_name());
		$navbar = new Navbar(self::$mHost->get_name(), $navModes, $navOptions);
		
		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('metahosts/view',array("mHost"=>self::$mHost),TRUE);
		$info['title'] = "Metahost - ".self::$mHost->get_name();
		
		// Load the main view
		$this->load->view('core/main',$info);
	}

	public function create() {
		if($this->input->post('submit')) {
			$mHost = $this->_create();
			self::$sidebar->reload();
			redirect(base_url()."firewall/metahosts/view/".rawurlencode($mHost->get_name()),'location');
		}
		else {
			// Navbar
            $navModes['CANCEL'] = "/firewall/metahosts/owned";
            $navbar = new Navbar("Create Metahost", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Get the preset form data for dropdown lists and things
			$form['user'] = $this->impulselib->get_username();
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}
			
			// Continue loading view data
			$info['data'] = $this->load->view('metahosts/create',$form,TRUE);
			$info['title'] = "Create Metahost";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}

	public function delete($metahostName=NULL) {
		if($metahostName == NULL) {
			$this->_error("No metahost specified");
		}
		$metahostName = rawurldecode($metahostName);
		try {
			self::$mHost = $this->api->firewall->get->metahost($metahostName,false);
		}
		catch (DBException $dbE) {
			$this->_error($dbE->getMessage());
		}
		catch (AmbiguousTargetException $atE) {
			$this->_error($atE->getMessage());
		}
		catch (ObjectNotFoundException $onfE) {
			$this->_error($onfE->getMessage());
		}
		
		// They hit yes, delete the metahost
		if($this->input->post('yes')) {
			try {
				$this->_delete(self::$mHost);
				self::$sidebar->reload();
				redirect(base_url()."firewall/metahosts/owned","location");
			}
			catch (DBException $dbE) {
				$this->_error("DB:".$dbE->getMessage());
			}
			catch (ObjectException $oE) {
				$this->_error("Obj:".$dbE->getMessage());
			}
		}
		
		// They hit no, don't delete the metahost
		elseif($this->input->post('no')) {
			redirect($this->input->post('url'),'location');
		}
		
		// Need to print the prompt
		else {
			// Navbar
            $navModes['CANCEL'] = "/firewall/metahosts/view/".rawurlencode($metahostName);
			$navbar = new Navbar("Delete Metahost", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Load the prompt information
			$prompt['message'] = "Delete metahost \"".self::$mHost->get_name()."\"?";
			$prompt['rejectUrl'] = $this->input->server('HTTP_REFERER');
			
			// Continue loading the view data
			$info['data'] = $this->load->view('core/prompt',$prompt,TRUE);	// Systems
			$info['title'] = "Delete System \"".self::$mHost->get_name()."\"";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}

	public function edit($metahostName=NULL) {
		if($metahostName == NULL) {
			$this->_error("No metahost specified");
		}
		$metahostName = rawurldecode($metahostName);
		try {
			self::$mHost = $this->api->firewall->get->metahost($metahostName,false);
		}
		catch (DBException $dbE) {
			$this->_error($dbE->getMessage());
		}
		catch (AmbiguousTargetException $atE) {
			$this->_error($atE->getMessage());
		}
		catch (ObjectNotFoundException $onfE) {
			$this->_error($onfE->getMessage());
		}
		
		// Information is there. Execute the edit
		if($this->input->post('submit')) {
			try {
				$this->_edit();
				self::$sidebar->reload();
				redirect(base_url()."firewall/metahosts/view/".rawurlencode(self::$mHost->get_name()),'location');
			}
			catch (ControllerException $cE) {
				$this->_error($cE->getMessage());
			}
		}
		else {
			// Navbar
			$navModes['CANCEL'] = "/firewall/metahosts/view/".rawurlencode($metahostName);
			$navbar = new Navbar("Edit Metahost", $navModes, null);
			
			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Get the preset form data for dropdown lists and things
			$form['mHost'] = self::$mHost;
			$form['user'] = $this->impulselib->get_username();
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}
			
			// Continue loading view data
			$info['data'] = $this->load->view('metahosts/edit',$form,TRUE);
			$info['title'] = "Edit Metahost";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}

	private function _create() {
		try {
			$mHost = $this->api->firewall->create_metahost(
				$this->input->post('name'),
				$this->input->post('owner'),
				$this->input->post('comment')
			);
		}
		catch (DBException $dbE) {
			$this->_error("DB: ".$dbE->getMessage());
			return;
		}
		catch (ObjectException $oE) {
			$this->_error("Obj: ".$oE->getMessage());
		}	
		catch (APIException $apiE) {
			$this->_error("API: ".$apiE->getMessage());
		}
		
		return $mHost;
	}

	private function _delete($mHost) {
		$this->api->firewall->remove->metahost($mHost);
	}

	private function _edit() {
		// The error return message
		$err = "";
		
		// Check for which field was modified
		if(self::$mHost->get_name() != $this->input->post('name')) {
			try { self::$mHost->set_name($this->input->post('name')); }
			catch (DBException $dbE) { $err .= $dbE->getMessage(); }
		}
		if(self::$mHost->get_comment() != $this->input->post('comment')) {
			try { self::$mHost->set_comment($this->input->post('comment')); }
			catch (DBException $dbE) { $err .= $dbE->getMessage(); }
		}
		if(self::$mHost->get_owner() != $this->input->post('owner')) {
			try { self::$mHost->set_owner($this->input->post('owner')); }
			catch (DBException $dbE) { $err .= $dbE->getMessage(); }
		}
		
		if($err != "") {
			throw new ControllerException($err);
		}
	}
}
/* End of file metahosts.php */
/* Location: ./application/controllers/firewall/metahosts.php */
