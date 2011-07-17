<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

require_once(APPPATH . "libraries/core/controller.php");

class Addresses extends IMPULSE_Controller {

	public function view($mac=NULL,$address=NULL,$target=NULL) {
		if($mac==NULL) {
			$this->error("No interface specified!");
		}
		
		if($address==NULL) {
			$this->error("No IP address specified!");
		}
		
		session_start();
		$int = $_SESSION['interfaces'][$mac];
		$addr = $int->get_address($address);
		
		// Navbar
		$navOptions['DNS Records'] = "/addresses/view/".$addr->get_mac()."/".$addr->get_address()."/dns";
		$navOptions['Firewall Rules'] = "/addresses/view/".$addr->get_mac()."/".$addr->get_address()."/firewall";
		$navOptions['All Addresses'] = "/interfaces/addresses/".$addr->get_mac();
		
		$navModes['EDIT'] = "";
		$navModes['DELETE'] = "/addresses/delete/".$addr->get_mac()."/".$addr->get_address();
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		
		switch($target) {
			case "dns":
				$viewData['address'] = $addr;
				$data = $this->load->view('dns/address', $viewData, TRUE);
				$info['title'] = "DNS - ".$addr->get_address();
				$navbar = new Navbar("DNS for ".$addr->get_address(), $navModes, $navOptions);
				break;
			case "firewall":
				$viewData['rules'] = $addr->get_rules();
				$viewData['deny'] = $addr->get_fw_default();
				$data = $this->load->view('firewall/address', $viewData, TRUE);
				$info['title'] = "Firewall Rules - ".$addr->get_address();
				$navbar = new Navbar("Firewall Rules for ".$addr->get_address(), $navModes, $navOptions);
				break;
			default:
				$viewData['help'] = $addr->get_help();
				$viewData['start'] = $addr->get_start();
				$data = $this->load->view('core/getstarted',$viewData,TRUE);
				$info['title'] = "Getting Started";
				$navbar = new Navbar("Getting Started", $navModes, $navOptions);
				break;
		}
		
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $data;

		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function create($mac=NULL) {
		if($mac == NULL) {
			$this->error("No interface specified!");
		}
		
		session_start();
		$int = $_SESSION['interfaces'][$mac];
		
		// Information is there. Create the address
		if($this->input->post('submit')) {
			$this->_create($int);
		}
		else {
			// Navbar
			$navModes['CANCEL'] = "";
			$navbar = new Navbar("Create Address", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Get the preset form data for dropdown lists and things
			$form['interface'] = $int;
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}
			$form['ranges'] = $this->api->ip->get_ranges();
			$form['configs'] = $this->api->dhcp->get_config_types();
			$form['classes'] = $this->api->dhcp->get_classes();
			
			// Continue loading view data
			$info['data'] = $this->load->view('addresses/create',$form,TRUE);
			$info['title'] = "Create Address";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	public function delete($mac=NULL,$address=NULL) {
		if($mac == NULL) {
			$this->error("No interface specified!");
		}
		
		session_start();
		$int = $_SESSION['interfaces'][$mac];
		
		// Information is there. Delete the address
		if($this->input->post('submit')) {
			$addr = $int->get_address($this->input->post('address'));
			$this->_delete($addr);
		}
		else {
			// Navbar
			$navModes['CANCEL'] = "";
			$navbar = new Navbar("Delete Address", $navModes, null);
			
			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Get the preset form data for dropdown lists and things
			$form['interface'] = $int;
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}
			$form['addresses'] = $int->get_interface_addresses();
			$form['address'] = $address;
			
			// Continue loading view data
			$info['data'] = $this->load->view('addresses/delete',$form,TRUE);
			$info['title'] = "Create Address";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	private function _create($int) {

		$isPrimary = ($this->input->post('isprimary')?"TRUE":"FALSE");
		
		$address = $this->input->post('address');
		if($address == "") {
			$address = $this->api->ip->get_address_from_range($this->input->post('range'));
		}
	
		$query = $this->api->systems->create_interface_address(
			$int->get_mac(),
			$address,
			$this->input->post('config'),
			$this->input->post('class'),
			$isPrimary,
			$this->input->post('comment')
		);
		
		if($query != "OK") {
			$this->error($query);
		}
		else {
			$address = $this->api->systems->get_system_inteface_address($address);
			$int->add_address($address);
			redirect(base_url()."/interfaces/addresses/".$int->get_mac()."/".$address->get_address(),'location');
		}
	}
	
	private function _delete($addr) {
		$query = $this->api->systems->remove_interface_address($addr);
		if($query != "OK") {
			$this->error($query);
		}
		else {
			redirect(base_url()."interfaces/addresses/".$addr->get_mac(),'location');
		}
	}
	
}
