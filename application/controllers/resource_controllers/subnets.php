<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "controllers/systems.php");

class Subnets extends ImpulseController {
	
	public static $sNet;
	
	public function __construct() {
		parent::__construct();
	}
	
	public function index() {
		$viewData = "";
		try {
			$sNets = $this->api->ip->get_subnets();
		}
		catch (ObjectNotFoundException $onfE) {
			$viewData = $this->_warning("No subnets configured!");
		}
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['title'] = "Subnets";
		$navbar = new Navbar("Subnets", null, null);


		foreach ($sNets as $sNet) {
			$viewData .= "<a href=\"/resources/subnets/view/".urlencode($sNet->get_subnet())."\">".$sNet->get_subnet()."</a>"."<br>";
		}
		
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $viewData;

		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function view($subnet=NULL) {
		$subnet = urldecode($subnet);
		self::$sNet = $this->api->ip->get_subnet($subnet);
	
		// Navbar
		$navOptions['Subnets'] = "/resources/subnets/";
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['title'] = "Subnet - ".self::$sNet->get_subnet();
		$navbar = new Navbar("Subnet - ".self::$sNet->get_subnet(), null, $navOptions);
		
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('subnets/view',array("sNet"=>self::$sNet),TRUE);

		// Load the main view
		$this->load->view('core/main',$info);
	}
}
/* End of file subnets.php */
/* Location: ./application/controllers/subnets.php */