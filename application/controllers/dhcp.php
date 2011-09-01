<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

/**
 * 
 */
class Dhcp extends ImpulseController {
	
	public function __construct() {
		parent::__construct();
		if(!$this->api->isadmin()) {
			$this->_error("Permission denied. You are not admin.");
		}
	}
	
	public function index() {
		// Navbar
		$navOptions['Classes'] = "/dhcp/classes";
		$navOptions['Global Options'] = "/dhcp/options/view/global";
		$navOptions['Reload'] = "/dhcp/reload";
		$navbar = new Navbar("DHCP", null, $navOptions);
	
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "DHCP";
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('dhcp/index',null,TRUE);

		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function reload() {
		// They hit yes, reload
		if($this->input->post('yes')) {
			
			try {
				$this->api->dhcp->reload();
				$this->_success("Reloaded all DHCP configuration! Please wait up to 1 minute before renewing your lease.");
			}
			catch (DBException $dbE) {
				echo $this->_error($dbE->getMessage());
			}
		}
		
		// They hit no, don't delete the class
		elseif($this->input->post('no')) {
			redirect(base_url()."dhcp",'location');
		}
		
		// Need to print the prompt
		else {
			// Navbar
            $navModes['CANCEL'] = "/dhcp";
			$navbar = new Navbar("Reload Configuration", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Load the prompt information
			$prompt['message'] = "Reload all DHCP configuration files?";
			$prompt['rejectUrl'] = $this->input->server('HTTP_REFERER');
			
			// Continue loading the view data
			$info['data'] = $this->load->view('core/prompt',$prompt,TRUE);	// Systems
			$info['title'] = "Reload DHCP";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
}
/* End of file dhcp.php */
/* Location: ./application/controllers/dhcp.php */
