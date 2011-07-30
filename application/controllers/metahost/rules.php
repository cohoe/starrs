<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Rules extends ImpulseController {

	public function index() {
		echo "Hello";
	}
	
	public function view($metahostName=NULL) {
		if($metahostName == NULL) {
			$this->_error("No metahost specified");
		}

        $this->_load_metahost($metahostName);
		
		// Navbar
		$navModes['CREATE'] = "/metahosts/rules/create/".self::$mHost->get_name();
		$navOptions['Overview'] = '/metahosts/view/'.self::$mHost->get_name();
		$navOptions['Members'] = '/metahosts/members/view/'.self::$mHost->get_name();
		$navOptions['Rules'] = '/metahosts/rules/view/'.self::$mHost->get_name();
		$navbar = new Navbar(self::$mHost->get_name()." - Rules", $navModes, $navOptions);
		
		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
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
			$mHostRule = $this->_create();
			redirect(base_url()."metahosts/rules/view/".self::$mHost->get_name(),'location');
		}
        else {
			// Navbar
            $navModes['CANCEL'] = "/metahosts/rules/view/".self::$mHost->get_name();
            $navbar = new Navbar("Create Metahost Rule", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);

			// Get the preset form data for dropdown lists and things
			$form['user'] = $this->impulselib->get_username();
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}
            $form['transports'] = $this->api->firewall->get_transports();
			$form['fwProgs'] = $this->api->firewall->get_programs();

			// Continue loading view data
			$info['data'] = $this->load->view('firewall/metahosts/rules/create',$form,TRUE);
			$info['title'] = "Create Metahost Rule";

			// Load the main view
			$this->load->view('core/main',$info);
		}
        
    }
	
	private function _load_rules() {
		try {
			$stdRules = $this->api->firewall->get_metahost_rules(self::$mHost->get_name());
			foreach($stdRules as $rule) {
				self::$mHost->add_rule($rule);
			}
		}
		catch (ObjectNotFoundException $onfE) { }
		try {
			$progRules = $this->api->firewall->get_metahost_program_rules(self::$mHost->get_name());
			foreach($progRules as $rule) {
				self::$mHost->add_rule($rule);
			}
		}
		catch (ObjectNotFoundException $onfE) { }
	
		if(count(self::$mHost->get_rules())) {
			return $this->load->view('firewall/metahosts/rule_overview',array("rules"=>self::$mHost->get_rules()),TRUE);
		}
		else {
			return $this->_warning("No rules found!");
		}
	}

    private function _create() {
        if($this->input->post('program')) {
			$fwRule = $this->api->firewall->create_metahost_program(
				self::$mHost->get_name(),
				$this->input->post('program'),
				$this->input->post('deny')
			);
		}
		else {
			$fwRule = $this->api->firewall->create_metahost_rule(
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