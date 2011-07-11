<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Classtest extends CI_Controller {
	
	public function index() {
		$sql = "SELECT * FROM systems.systems WHERE owner = 'user'";
		$query = $this->db->query($sql);

		foreach ($query->result() as $system) {
			$sys = new System($system->system_name);
			$this->load->view('systemtest',array('system'=>$sys));
		}
	}
	
	public function view($system_name=NULL) {
		$this->_css();
		if(!$system_name) {
			echo "You need to specify a system";
			die;
		}
		
		$system_info = $this->api->get_system_info($system_name);
		$sys = new System($system_info['system_name']);
		$this->load->view('systemtest',array('system'=>$sys));
		
		foreach ($sys->get_interfaces() as $interface) {
			$this->load->view('interfacetest',array("interface"=>$interface));
			
			foreach ($interface->get_interface_addresses() as $address) {
				$this->load->view('addresstest',array("address"=>$address));
				$this->_print_firewall_rules($address);
			}
		}
	}
	
	private function _css() {
		$skin = "grid";
		if(isset($_GET['skin'])) {
			$skin = $_GET['skin'];
		}

		echo link_tag("css/$skin/full/main.css");
	}
	
	private function _print_firewall_rules($address) {
		#foreach ($address->get_rules() as $rule) {
		#	$this->load->view('rulestest',array("rule"=>$rule));
		#}
	}
}

/* End of file classtest.php */
