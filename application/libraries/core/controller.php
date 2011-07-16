<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class IMPULSE_Controller extends CI_Controller {

	/**
	 * Print an error message (thrown by the DB)
     * @param $message
     * @return void
     */
	public function error($message) {
		// Navbar
		$navbar = new Navbar("Error", null, null);

		$data['message'] = $message;
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('core/error',$data,TRUE);
		$info['title'] = "Error";
		
		// Load the main view
		$this->load->view('core/main',$info);
	}
	
	/**
	 * Print a success message
     * @param $message
     * @return void
     */
	public function success($message) {
		// Navbar
		$navOptions['Back'] = $this->input->server('HTTP_REFERER');
		$navbar = new Navbar("Success", null, $navOptions);
		
		$data['message'] = $message;
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('core/success',$data,TRUE);
		$info['title'] = "Success";
		
		// Load the main view
		$this->load->view('core/main',$info);
	}	
	
	/**
	 * Print a warning message
     * @param $message
     * @return void
     */
	public function warning($message) {
		// Navbar
        #$navbar = new Navbar("Warning", null, null);
		
		$data['message'] = $message;
		
		// Load view data
		#$info['header'] = $this->load->view('core/header',"",TRUE);
		#$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		#$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		#$info['data'] = $this->load->view('core/warning',$data,TRUE);
		#$info['title'] = "Warning";
		
		// Load the main view
		#$this->load->view('core/main',$info);
		
		return $this->load->view('core/warning',$data,TRUE);
	}

}
