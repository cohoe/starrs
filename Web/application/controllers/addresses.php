<?php if ( ! defined('BASEPATH')) 'No direct script access allowed';
require_once(APPPATH . "libraries/core/ImpulseController.php");

/**
 * Interface addresses. Create/Edit/Delete/View all information and objects that are based on the InterfaceAddresses
 */
class Addresses extends ImpulseController {

	/**
     * See the various addresses on the interface. 
     * @param null $mac The MAC address of the interface to view
     * @return
     */
	public function view($mac=NULL) {

        // If the user did something silly.
		if($mac ==  NULL) {
			$this->_error("No interface was given!");
		}
		
		$mac = rawurldecode($mac);
		self::$int = $this->_load_interface($mac);

		// Navbar
		$navModes['CREATE'] = "/address/create/".rawurlencode($mac);
		$navOptions['Interfaces'] = "/interfaces/view/".rawurlencode(self::$int->get_system_name());
		$navbar = new Navbar("Addresses on {$mac}", $navModes, $navOptions);

		// Load the view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->_load_addresses(self::$int);
		$info['title'] = "Addresses - $mac";
		
		// Load the main view
		$this->load->view('core/main',$info);
	}
}
/* End of file addresses.php */
/* Location: ./application/controllers/addresses.php */
