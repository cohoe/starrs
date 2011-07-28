<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");
/**
 * 
 */
class Admin extends ImpulseController {
	
	public function __construct() {
		parent::__construct();
	}
	
	public function index() {
		if($this->api->isadmin() == false) {
			$this->_error("Permission denied. You are not an IMPULSE administrator");
			return;
		}
		$this->load->library('table');

		$query = $this->db->query("SELECT option,value FROM management.configuration");
		$tmpl = array (
			'table_open'          => '<table border="0" cellpadding="4" cellspacing="0">',

			'heading_row_start'   => '<tr>',
			'heading_row_end'     => '</tr>',
			'heading_cell_start'  => '<th>',
			'heading_cell_end'    => '</th>',

			'row_start'           => '<tr bgcolor=#cccccc>',
			'row_end'             => '</tr>',
			'cell_start'          => '<td>',
			'cell_end'            => '</td>',

			'row_alt_start'       => '<tr bgcolor=#b9b9b9>',
			'row_alt_end'         => '</tr>',
			'cell_alt_start'      => '<td>',
			'cell_alt_end'        => '</td>',

			'table_close'         => '</table>'
		);

		$this->table->set_template($tmpl);
		$data = $this->table->generate($query);
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['title'] = "IMPULSE Site Configuration";
		$navbar = new Navbar("Site Configuration", null, null);
		
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $data;

		// Load the main view
		$this->load->view('core/main',$info);
	}
}

/* End of file admin.php */
/* Location: ./application/controllers/admin.php */