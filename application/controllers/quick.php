<?php if ( ! defined('BASEPATH')) 'No direct script access allowed';
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Quick extends ImpulseController {
	
	public function create() {
		if($this->input->post('submit')) {
			$address = $this->input->post('address');
			if($address == "") {
				$address = $this->api->ip->get->address_from_range($this->input->post('range'));
			}
			
			try {
				$this->api->systems->create->system_quick($this->input->post('systemName'), $this->input->post('osName'), $this->input->post('mac'), $address);
				redirect(base_url()."systems/view/".rawurlencode($this->input->post('systemName')),'location');
			}
			catch(DBException $dbE) {
				$this->_error($dbE->getMessage());
			}
			catch(Exception $e) {
				$this->_error("H".$e->getMessage());
			}
		}
		
		// Navbar
		$navModes['CANCEL'] = "/";
		$navbar = new Navbar("Quick Create System", $navModes, null);

		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		
		// Get the preset form data for dropdown lists and things
		$form['operatingSystems'] = $this->api->systems->get->operating_systems();
		$form['systemTypes'] = $this->api->systems->get->system_types();
		$form['user'] = $this->api->get->current_user();
		$form['ranges'] = $this->api->ip->get->ranges();
		if($this->api->isadmin() == TRUE) {
			$form['admin'] = TRUE;
		}
		
		// Continue loading view data
		$info['data'] = $this->load->view('systems/quickcreate',$form,TRUE);
		$info['title'] = "Quick Create System";
		
		// Load the main view
		$this->load->view('core/main',$info);
	}
}
/* End of file quick.php */
/* Location: ./application/controllers/quick.php */