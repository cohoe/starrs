<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");
/**
 * 
 */
class Queue extends ImpulseController {
	public function view($target=NULL) {
		// Navbar
		$navModes['EDIT'] = "/admin/configuration/edit/site";
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['title'] = "Queue";
		$navbar = new Navbar("Queue", $navModes, null);
		
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		
		switch($target) {
			case "dns":
				$info['data'] = $this->_load_dns_queue();
				break;
			case "firewall_rules":
				$info['data'] = $this->_load_firewall_rule_queue();
				break;
			case "firewall_defaults":
				break;
			case "default":
				$info['data'] = $this->_warning("No view specified");
		}
		
		// Load the main view
		$this->load->view('core/main',$info);
		
	}
	
	private function _load_firewall_rule_queue() {
		$query = $this->db->query("SELECT * FROM firewall.rule_queue");
		return $this->table->generate($query);
	}
	
	private function _load_dns_queue() {
		$query = $this->db->query("SELECT * FROM api.get_dns_queue()");
		return $this->table->generate($query);
	}
}
/* End of file queue.php */
/* Location: ./application/controllers/process_controllers/queue.php */