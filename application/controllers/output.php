<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Output extends ImpulseController {

	public function __construct() {
		parent::__construct();
	}
	
	public function index() {
		// Navbar
		$navOptions['dhcpd.conf'] = "/output/view/dhcpd.conf";
		$navOptions['Firewall Default Queue'] = "/output/view/fw_default_queue";
		$navbar = new Navbar("Output", null, $navOptions);

		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "Output";
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('output/list',null,TRUE);
		
		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function view($target=NULL) {
		if($target==NULL) {
			$this->_error("No target for viewing specified");
		}
		$target = urldecode($target);
		
		switch($target) {
			case "dhcpd.conf":
				if(!$this->api->isadmin()) {
					$this->_error("Permission denied. You are not admin.");
				}
				$info['data'] = $this->_dhcpdConf();
				break;
			case "fw_default_queue":
				$info['data'] = $this->_fwDefaultQueue();
				break;
			default:
				$info['data'] = $this->_warning("Invalid view specified");
				break;
		}
		
		// Navbar
		$navOptions['dhcpd.conf'] = "/output/view/dhcpd.conf";
		$navOptions['Firewall Default Queue'] = "/output/view/fw_default_queue";
		$navbar = new Navbar($target, null, $navOptions);

		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = $target;
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		
		// Load the main view
		$this->load->view('core/main',$info);
	}

	private function _dhcpdConf() {
		#$sql = "select value from management.output where file='dhcpd.conf' order by output_id desc limit 1";
		$sql = "SELECT api.get_dhcpd_config()";
		$query = $this->db->query($sql);
		$output = $query->row()->get_dhcpd_config;
		return "<pre style=\"padding: 5px;	\">$output</pre>";
	}
	
	private function _fwDefaultQueue() {
		$sql = "select * from firewall.default_queue";
		$query = $this->db->query($sql);
		return $this->table->generate($query);
	}
}
/* End of file output.php */
/* Location: ./application/controllers/output.php */
