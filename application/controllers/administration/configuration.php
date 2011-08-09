<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");
/**
 * 
 */
class Configuration extends ImpulseController {
	
	public function __construct() {
		parent::__construct();
		if($this->api->isadmin() == false) {
			$this->_error("Permission denied. You are not an IMPULSE administrator");
		}
	}	
	
	public function view($mode=NULL) {
		switch($mode) {
			case "site":
				$this->_view_site_configuration();
				break;
			default:
				$this->_error("No view object specified");
		}
	}
	
	public function edit($mode=NULL) {
		$editTemplate = array (
			'table_open'          => '<table border="0" cellpadding="4" cellspacing="0">',

			'heading_row_start'   => '<tr>',
			'heading_row_end'     => '</tr>',
			'heading_cell_start'  => '<th>',
			'heading_cell_end'    => '</th>',

			'row_start'           => '<tr bgcolor=#cccccc>',
			'row_end'             => '</tr>',
			'cell_start'          => '<td><input type="text">',
			'cell_end'            => '</input></td>',

			'row_alt_start'       => '<tr bgcolor=#b9b9b9>',
			'row_alt_end'         => '</tr>',
			'cell_alt_start'      => '<td><input type="text">',
			'cell_alt_end'        => '</input></td>',

			'table_close'         => '</table>'
		);
			
		#$this->table->set_template($editTemplate);
		
		$query = $this->db->query("SELECT option,value FROM management.configuration");
		
		// Navbar
		$navModes['EDIT'] = "/admin/configuration/edit/site";
		$navModes['CANCEL'] = "/admin/configuration/view/site";

		foreach($query->result_array() as $result) {
			$this->table->add_row($result['option'],"<input type=\"text\" style=\"width: 100%;\" value=\"$result[value]\"></input>");
		}
		
		$data = $this->table->generate();
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "IMPULSE Site Configuration";
		$navbar = new Navbar("Site Configuration", $navModes, null);
		
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $data;

		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	private function _view_site_configuration() {
		$query = $this->db->query("SELECT option,value FROM management.configuration");
		
		// Navbar
		$navModes['EDIT'] = "/admin/configuration/edit/site";

		$data = $this->table->generate($query);
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "IMPULSE Site Configuration";
		$navbar = new Navbar("Site Configuration", $navModes, null);
		
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $data;

		// Load the main view
		$this->load->view('core/main',$info);
	}
}

/* End of file admin.php */
/* Location: ./application/controllers/admin.php */