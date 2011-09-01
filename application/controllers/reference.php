<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

/**
 * This controller handles all information regarding the system objects. You can create, edit, and delete systems
 * that you have permission to do so on. 
 */
class Reference extends ImpulseController {

    /**
	 * If no additional URL paramters were specified, load this default view
     * @return void
     */
	public function index() {
		// Navbar
        $navOptions = array('API Reference'=>'/reference/api', 'Help System'=>'/reference/help');
        $navbar = new Navbar("Reference", null, $navOptions);
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$viewData['help'] = "This area contains all of the documentation for the IMPULSE application. The API reference describes all of the functions available to developers.";
		$viewData['start'] = "";
		$info['data'] = $this->load->view('core/getstarted',$viewData,TRUE);
		$info['title'] = "Reference";
		
		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function api($schema=NULL) {
	
		if($schema == 'none') {
			$this->_load_api_functions("none");
		}
		elseif($schema == 'all') {
			try {
				$this->_load_api_functions("all");
			}
			catch(Exception $e) {
				$this->_error($e->getMessage());
			}
		}
		elseif($schema != NULL) {
			try {
				$this->_load_api_functions($schema);
			}
			catch(Exception $e) {
				$this->_error($e->getMessage());
			}
		}
		else {
			// Navbar
			$navOptions = array('API Reference'=>'/reference/api', 'Help System'=>'/reference/help');
			$navbar = new Navbar("API Reference", null, $navOptions);
			
			// Load view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $this->load->view("reference/index",null,TRUE);
			$info['title'] = "API Reference";
			
			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	private function _load_api_functions($schema) {
		$functions = $this->api->documentation->get_schema_documentation($schema);
		
		$viewData = "";
		foreach ($functions as $function) {
			$arguments = $this->api->documentation->get_function_parameters($function['specific_name']);
			$function['args'] = $arguments;
			$viewData .= $this->load->view('reference/function.php', $function, TRUE);
		}
		
		// Navbar
		$navOptions = array('API Reference'=>'/reference/api', 'Help System'=>'reference/help');
		$navbar = new Navbar("API Reference", null, $navOptions);
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view("core/data",array('data'=>$viewData),TRUE);
		$info['title'] = "API Reference";
		
		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	public function help($object=NULL,$view=NULL) {
		// Navbar
        $navOptions = array('API Reference'=>'/reference/api', 'Help System'=>'reference/help');
        $navbar = new Navbar("Help", null, $navOptions);
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		if($view) {
			$info['data'] = $this->load->view("help/$object/$view",null,TRUE);
		}
		elseif($object) {
			$info['data'] = $this->load->view("help/$object.php",null,TRUE);
		}
		else {
			$info['data'] = $this->load->view("help/welcome",null,TRUE);
		}
		$info['title'] = "Help: $object/$view";
		
		// Load the main view
		$this->load->view('core/main',$info);
	}
}
/* End of file reference.php */
/* Location: ./application/controllers/reference.php */
