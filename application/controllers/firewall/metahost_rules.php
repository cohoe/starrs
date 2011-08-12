<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Metahost_rules extends ImpulseController {

	public function index() {
		$this->_error("No action or metahost was given");
	}
	
	public function view($metahostName=NULL) {
		if($metahostName == NULL) {
			$this->_error("No metahost specified");
		}

        $this->_load_metahost($metahostName);
		
		// Navbar
		$navModes['CREATE'] = "/firewall/metahost_rules/create/".rawurlencode(self::$mHost->get_name());
		$navOptions['Overview'] = '/firewall/metahosts/view/'.rawurlencode(self::$mHost->get_name());
		$navOptions['Members'] = '/firewall/metahost_members/view/'.rawurlencode(self::$mHost->get_name());
		$navOptions['Rules'] = '/firewall/metahost_rules/view/'.rawurlencode(self::$mHost->get_name());
		$navbar = new Navbar(self::$mHost->get_name()." - Rules", $navModes, $navOptions);
		
		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		try {
			$info['data'] = $this->_load_rules();
		}
		catch (DBException $dbE) {
			$this->_error($dbE->getMessage());
		}
		$info['title'] = "Metahost - ".self::$mHost->get_name();
		
		// Load the main view
		$this->load->view('core/main',$info);
	}

    public function create($metahostName=NULL) {
        if($metahostName == NULL) {
			$this->_error("No metahost specified");
		}

        $this->_load_metahost($metahostName);

        if($this->input->post('submit')) {
            try {
                $mHostRule = $this->_create();
				self::$sidebar->reload();
                redirect(base_url()."firewall/metahost_rules/view/".rawurlencode(self::$mHost->get_name()),'location');
            }
            catch (DBException $dbE) {
                $this->_error($dbE->getMessage());
            }
		}
        else {
			// Navbar
            $navModes['CANCEL'] = "/firewall/metahost_rules/view/".rawurlencode(self::$mHost->get_name());
            $navbar = new Navbar("Create Metahost Rule", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);

			// Get the preset form data for dropdown lists and things
			$form['user'] = $this->impulselib->get_username();
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}
            $form['transports'] = $this->api->firewall->get->transports();
			$form['fwProgs'] = $this->api->firewall->get->programs();

			// Continue loading view data
			$info['data'] = $this->load->view('metahosts/rule_create',$form,TRUE);
			$info['title'] = "Create Metahost Rule";

			// Load the main view
			$this->load->view('core/main',$info);
		}
        
    }

    public function delete($metahostName=NULL,$transport=NULL,$port=NULL) {
        if($metahostName == NULL) {
			exit($this->_error("No metahost specified"));
		}
        if($transport==NULL) {
			$this->_error("No transport specified");
		}
		if($port==NULL) {
			$this->_error("No port specified");
		}

        $this->_load_metahost($metahostName);

        try {
			self::$fwRule = self::$mHost->get_rule($port,$transport);
		}
		catch (ObjectNotFoundException $onfE) {
			$this->_error($onfE->getMessage());
		}

		try {
			if(self::$fwRule->get_source() == 'standalone-program') {
				$this->api->firewall->remove->standalone_program(self::$fwRule->get_address(),self::$fwRule->get_program_name());
			}
			else {
				$this->api->firewall->remove->standalone_rule(self::$fwRule->get_address(),self::$fwRule->get_port(),self::$fwRule->get_transport());
			}

			// Move along
			self::$sidebar->reload();
			redirect(base_url()."firewall/metahost_rules/view/".rawurlencode(self::$mHost->get_name()),'location');
		}
		catch (DBException $dbE) {
			$this->_error($dbE->getMessage());
			return;
		}
    }
	
	private function _load_rules() {
		if(count(self::$mHost->get_rules())) {
			return $this->load->view('metahosts/rule_overview',array("rules"=>self::$mHost->get_rules(),"mHost"=>self::$mHost),TRUE);
		}
		else {
			return $this->_warning("No rules found!");
		}
	}

    private function _create() {
        if($this->input->post('program')) {
			$fwRule = $this->api->firewall->create->metahost_program(
				self::$mHost->get_name(),
				$this->input->post('program'),
				$this->input->post('deny')
			);
		}
		else {
			$fwRule = $this->api->firewall->create->metahost_rule(
				self::$mHost->get_name(),
				$this->input->post('port'),
				$this->input->post('transport'),
				$this->input->post('deny'),
				$this->input->post('comment')
			);
		}

		return $fwRule;
    }
}
/* End of file rules.php */
/* Location: ./application/controllers/metahost/rules.php */