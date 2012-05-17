<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");
/**
 * 
 */
class Siteconfig extends ImpulseController {
	
	public function __construct() {
		parent::__construct();
		if($this->api->isadmin() == false) {
			$this->_error("Permission denied. You are not an IMPULSE administrator");
		}
	}	
	
	public function view() {
		// Get the configuration data query
		$configData = $this->api->get->site_configuration_all();
		
		// Generate the table
		$this->table->set_heading('Option', 'Value');
		foreach($configData->result_array() as $directive) {
			$this->table->add_row("<a href=\"/admin/siteconfig/edit/{$directive['option']}\">".$directive['option'].'</a>', $directive['value']);
		}
		$data = $this->table->generate();
		
		// Navbar
		$navbar = new Navbar("Site Configuration", null, null);
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "Site Configuration";
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $data;

		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function edit($directive=NULL) {
		if($directive == NULL) {
			$this->_error("No configuration directive given");
		}
		
		try {
			$formData['option'] = $directive;
			$formData['value'] = $this->api->get->site_configuration($directive);
		}
		catch(Exception $e) {
			$this->_error($e->getMessage());
		}
		
		if($this->input->post('submit')) {
			if($formData['value'] != $this->input->post('value')) {
				try {
					$this->api->modify->site_configuration($formData['option'], $this->input->post('value'));
				}
				catch(Exception $e) {
					$this->_error($e->getMessage());
				}
			}
			redirect(base_url()."admin/siteconfig/view",'location');
		}
		
		// Navbar
		$navModes['CANCEL'] = "/admin/siteconfig/view/";
		$navbar = new Navbar("Site Configuration", $navModes, null);
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "Site Configuration";
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('config/site_edit.php',$formData,true);
		
		// Load the main view
		$this->load->view('core/main',$info);
	}
}
/* End of file siteconfig.php */
/* Location: ./application/controllers/administration/siteconfig.php */