<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "controllers/systems.php");

class Zones extends ImpulseController {
	
	public static $dnsZone;
	
	public function __construct() {
		parent::__construct();
	}
	
	public function index() {
		try {
			$dnsZones = $this->api->dns->get_zones(null);
		}
		catch (ObjectNotFoundException $onfE) {
			$viewData = $this->_warning("No DNS zones configured");
		}
		catch (DBException $dbE) {
			$this->_error($dbE->getMessage());
		}
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['title'] = "DNS Zones";
		$navbar = new Navbar("DNS Zones", null, null);

		$viewData = $this->load->view("resources/zones/list",array("dnsZones"=>$dnsZones),TRUE);
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $viewData;

		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function view($zone=NULL) {
		$zone = urldecode($zone);
		self::$dnsZone = $this->api->dns->get_zone($zone);
	
		// Navbar
		$navOptions['Zones'] = "/resources/zones/";
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['title'] = "Zone - ".self::$dnsZone->get_zone();
		$navbar = new Navbar("Zone - ".self::$dnsZone->get_zone(), null, $navOptions);
		
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('resources/zones/view',array("dnsZone"=>self::$dnsZone),TRUE);

		// Load the main view
		$this->load->view('core/main',$info);
	}
}
/* End of file zones.php */
/* Location: ./application/controllers/zones.php */