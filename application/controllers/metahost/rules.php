<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Rules extends ImpulseController {
	
	public static $mHost;
	
	public function index() {
		echo "Hello";
	}
	
	public function view($metahostName=NULL) {
		if($metahostName == NULL) {
			$this->_error("No metahost specified");
			return;
		}
		try {
			self::$mHost = $this->api->firewall->get_metahost($metahostName,false);
		}
		catch (DBException $dbE) {
			$this->_error($dbE->getMessage());
			return;
		}
		catch (AmbiguousTargetException $atE) {
			$this->_error($atE->getMessage());
			return;
		}
		catch (ObjectNotFoundException $onfE) {
			$this->_error($onfE->getMessage());
			return;
		}
		
		// Navbar
		$navModes['DELETE'] = "/metahosts/rules/delete/".self::$mHost->get_name();
		$navOptions['Members'] = '/members/view/'.self::$mHost->get_name();
		$navOptions['Rules'] = '/metahosts/rules/view/'.self::$mHost->get_name();
		$navbar = new Navbar(self::$mHost->get_name(), $navModes, $navOptions);
		
		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->_load_rules();
		$info['title'] = "Metahost - ".self::$mHost->get_name();
		
		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	private function _load_rules() {
		$viewData = "";
		$stdRules = $this->api->firewall->get_metahost_rules(self::$mHost->get_name());
		foreach($stdRules as $rule) {
			self::$mHost->add_rule($rule);
		}
		
		$progRules = $this->api->firewall->get_metahost_program_rules(self::$mHost->get_name());
		foreach($progRules as $rule) {
			self::$mHost->add_rule($rule);
		}
		
		$viewData = $this->load->view('firewall/metahosts/rule_overview',array("rules"=>self::$mHost->get_rules()),TRUE);
		
		return $viewData;
	}
}
/* End of file rules.php */
/* Location: ./application/controllers/metahost/rules.php */