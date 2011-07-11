<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Oldsystems extends CI_Controller {

	public function index() {
		$this->_css();

        $systems = $this->api->get_systems(null);
        foreach ($systems as $sys) {
            $this->load->view('systems/system',array('system'=>$sys));
        }
	}

	public function view($system_name=NULL) {
		$this->_css();
		if(!$system_name) {
			echo "You need to specify a system";
			die;
		}

		$sys = $this->api->get_system_info($system_name,true);
		$this->load->view('systems/system',array('system'=>$sys));

		foreach ($sys->get_interfaces() as $interface) {
			$this->load->view('systems/interface',array("interface"=>$interface));
			foreach ($interface->get_interface_addresses() as $address) {
				$this->load->view('ip/address',array("address"=>$address));
				$this->_print_firewall_rules($address);
				$this->_print_dns_records($address);
			}
		}
	}
	
	private function _css() {
		$skin = "impulse";
		#$skin = "grid";
		if(isset($_GET['skin'])) {
			$skin = $_GET['skin'];
		}

		echo link_tag("css/$skin/full/main.css");
	}
	
	private function _print_firewall_rules($address) {
        // Preload the data for the view
		$rule_info['rules'] = $address->get_rules();
		$rule_info['deny'] = $address->get_fw_default();
		$rule_info['address'] = $address->get_address();

        // Load the view
		$this->load->view('firewall/rules',$rule_info);
	}
	
	private function _print_dns_records($address) {
		$record_info['address_record'] = $address->get_address_record();
		$record_info['pointer_records'] = $address->get_pointer_records();
		$record_info['ns_records'] = $address->get_ns_records();
		$record_info['mx_records'] = $address->get_mx_records();
		$record_info['text_records'] = $address->get_text_records();
		$record_info['address'] = $address->get_address();
		
		$this->load->view('dns/records',$record_info);
	}
}

/* End of file systems.php */
