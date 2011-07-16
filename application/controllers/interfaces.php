<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

require_once(APPPATH . "libraries/core/controller.php");

class Interfaces extends IMPULSE_Controller {

	public function index() {
		echo "Interfaces";
	}
	
	public function create($systemName=NULL) {
	
		if($systemName == NULL) {
			$this->error("No system was specified");
		}
		
		else {
			// Information is there. Create the system
			if($this->input->post('submit')) {
				$this->_create();
			}
			
			// Need to input the information
			else {
				// Navbar
				$navModes['CANCEL'] = "";
				$navbar = new Navbar("Create Interface", $navModes, null);

				// Load the view data
				$info['header'] = $this->load->view('core/header',"",TRUE);
				$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
				$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
				
				// Get the preset form data for dropdown lists and things
				$form['systems'] = $this->api->systems->get_systems($this->impulselib->get_username());
				if($this->api->isadmin() == true) {
					$form['systems'] = $this->api->systems->get_systems(NULL);
				}
				$form['systemName'] = $systemName;
				if($this->api->isadmin() == TRUE) {
					$form['admin'] = TRUE;
				}
				
				// Continue loading view data
				$info['data'] = $this->load->view('interfaces/create',$form,TRUE);
				$info['title'] = "Create Interface";
				
				// Load the main view
				$this->load->view('core/main',$info);
			}
		}
	}
	
	public function edit($mac=NULL) {
		if($mac == NULL) {
			$this->error("No interface was specified");
		}
		
		#$interface = $this->api->systems->get_system_interface_data($mac);
		session_start();
		$interface = $_SESSION['interfaces'][$mac];
		
		// Information is there. Execute the edit
		if($this->input->post('submit')) {
			$this->_edit($interface);
		}
		
		// Need to input the information
		else {
			// Navbar
			$navModes['CANCEL'] = "";
			$navbar = new Navbar("Edit Interface", $navModes, null);
			
			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Get the preset form data for dropdown lists and things
			$form['systems'] = $this->api->systems->get_systems($this->impulselib->get_username());
			if($this->api->isadmin() == true) {
				$form['systems'] = $this->api->systems->get_systems(NULL);
			}
			$form['interface'] = $interface;
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}
			
			// Continue loading view data
			$info['data'] = $this->load->view('interfaces/edit',$form,TRUE);
			$info['title'] = "Edit Interface";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	public function delete($mac) {
	
		if($mac == NULL) {
			$this->error("No interface was specified");
		}
		
		$interface = $this->api->systems->get_system_interface_data($mac);
		
		// They hit yes, delete the system
		if($this->input->post('yes')) {
			$this->_delete($interface);
		}
		
		// They hit no, don't delete the system
		elseif($this->input->post('no')) {
			redirect($this->input->post('url'),'location');
		}
		
		// Need to print the prompt
		else {
			// Navbar
            $navModes['CANCEL'] = "";
			$navbar = new Navbar("Delete Interface", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			
			// Load the prompt information
			$prompt['message'] = "Delete interface \"".$interface->get_interface_name()."\"?";
			$prompt['rejectUrl'] = $this->input->server('HTTP_REFERER');
			
			// Continue loading the view data
			$info['data'] = $this->load->view('core/prompt',$prompt,TRUE);	// Systems
			$info['title'] = "Delete Interface \"".$interface->get_interface_name()."\"";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	public function addresses($mac=NULL) {
		if($mac ==  NULL) {
			$this->error("No interface was given!");
			return;
		}
		
		$int = $this->api->systems->get_system_interface_data($mac, false);
		
		// Navbar
		$navModes['CREATE'] = "/addresses/create/".$mac;
		$navModes['DELETE'] = "/addresses/delete/".$mac;
		$navOptions['Interfaces'] = "/systems/view/".$int->get_system_name()."/interfaces";
		$navbar = new Navbar("Addresses on " . $mac, $navModes, $navOptions);

		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		
		$info['data'] = $this->_load_addresses($int);
		$info['title'] = "Addresses - ".$mac;
		
		// Load the main view
		$this->load->view('core/main',$info);
		
		$_SESSION['interfaces'][$int->get_mac()] = $int;
	}
	
	private function _create() {
		$query = $this->api->systems->create_interface(
			$this->input->post('systemName'),
			$this->input->post('mac'),
			$this->input->post('name'),
			$this->input->post('comment')
		);
		
		if($query != "OK") {
			$this->error($query);
		}
		else {
			redirect(base_url()."systems/view/".$this->input->post('systemName')."/interfaces",'location');
		}
	}
	
	private function _edit($interface) {
		$err = "";
		
		if($interface->get_system_name() != $this->input->post('systemName')) {
			try { $interface->set_system_name($this->input->post('systemName')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if($interface->get_interface_name() != $this->input->post('name')) {
			try { $interface->set_interface_name($this->input->post('name')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if($interface->get_comment() != $this->input->post('comment')) {
			try { $interface->set_comment($this->input->post('comment')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		if($interface->get_mac() != $this->input->post('mac')) {
			try { $interface->set_mac($this->input->post('mac')); }
			catch (APIException $apiE) { $err .= $apiE->getMessage(); }
		}
		
		if($err != "") {
			$this->error($err);
		}
		else {
			redirect(base_url()."systems/view/".$this->input->post('systemName')."/interfaces",'location');
		}
	}
	
	private function _delete($interface) {
		$query = $this->api->systems->remove_interface($interface);
		if($query != "OK") {
			$this->error($query);
		}
		else {
			redirect(base_url()."systems/view/".$interface->get_system_name()."/interfaces",'location');
		}
	}
	
	private function _load_addresses($int) {
		$addressViewData = "";
		
		$addrs = $this->api->systems->get_system_interface_addresses($int->get_mac(), true);
		#$addrs = $int->get_interface_addresses();
		
		session_start();
		
		foreach($addrs as $address) {
			$navbar = new Navbar("Address", null, null);
			$addressViewData .= $this->load->view('systems/address',array('address'=>$address, 'navbar'=>$navbar),TRUE);
			#$_SESSION['intaddrs'][$address->get_address()] = $address;
			$int->add_address($address);
		}
		
		if(count($addrs) == 0) {
			return $this->warning("No addresses found!");
		}
		else {
			return $addressViewData;
		}
	}	
}

/* End of file interfaces.php */
/* Location: ./application/controllers/interfaces.php */