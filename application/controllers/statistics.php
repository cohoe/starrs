<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Statistics extends ImpulseController {

    /**
     * @return void
     */
	public function index() {
		
		// Information
		$navbar = new Navbar("Statistics", null, null);
        
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('statistics/getstarted',array(),TRUE);
		$info['title'] = "Statistics";
		
		// Load the main view
		$this->load->view('core/main',$info);
	}			

    /**
     * @return void
     */
	public function os_distribution() {
		$data = $this->api->statistics->get->os_distribution();
		
		// Information
		$navbar = new Navbar("Statistics - Operating System Distribution", null, null);
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('statistics/os_distribution',array("data"=>$data),TRUE);
		$info['title'] = "OS Distribution";
		
		// Load the main view
		$this->load->view('core/main',$info);
	}

    /**
     * @return void
     */
	public function os_family_distribution() {
		$data = $this->api->statistics->get->os_family_distribution();
		
		// Information
		$navbar = new Navbar("Statistics - Operating System Family Distribution", null, null);
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('statistics/os_family_distribution',array("data"=>$data),TRUE);
		$info['title'] = "OS Family Distribution";
		
		// Load the main view
		$this->load->view('core/main',$info);
	}

    public function range_utilization($range=NULL) {
        $range = rawurldecode($range);
        $data = $this->api->statistics->get->range_utilization($range);

		// Information
		$navbar = new Navbar("Statistics - Range Utilization", null, null);

		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('statistics/range_utilization',array("data"=>$data),TRUE);
		$info['title'] = "Range Utilization";

		// Load the main view
		$this->load->view('core/main',$info);
    }

     public function subnet_utilization($subnet=NULL) {
        $subnet = rawurldecode($subnet);
        $data = $this->api->statistics->get->subnet_utilization($subnet);

		// Information
		$navbar = new Navbar("Statistics - Subnet Utilization", null, null);

		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('statistics/subnet_utilization',array("data"=>$data),TRUE);
		$info['title'] = "Subnet Utilization";

		// Load the main view
		$this->load->view('core/main',$info);
    }
}
