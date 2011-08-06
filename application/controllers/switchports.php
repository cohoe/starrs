<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Switchports extends ImpulseController {

   # public static $sPort;

    public function view($systemName=NULL) {
        if($systemName==NULL) {
            $this->_error("No system specified for viewing");
        }
    }

    public function create($systemName=NULL) {
        if($systemName==NULL) {
            $this->_error("No system specified for create");
        }

        $systemName = urldecode($systemName);
        $this->_get_system($systemName);

        // Navbar
		$navOptions['Something'] = "Something";
		$navModes['CREATE'] = "/switchports/create/".urlencode(self::$sys->get_system_name());
        $navbar = new Navbar("Switchports on ".self::$sys->get_system_name(), $navModes, $navOptions);

		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['title'] = "Switchports on ".self::$sys->get_system_name();
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = "Switchports!";

		// Load the main view
		$this->load->view('core/main',$info);
    }

    private function _get_system($systemName) {
        try {
            self::$sys = $this->api->systems->get->system($systemName);
        }
        catch (ObjectNotFoundException $onfE) {
            $this->_error("System \"$systemName\" not found.");
        }
        catch (DBException $dbE) {
            $this->_error($dbE->getMessage());
        }
    }
}
/* End of file switchports.php */
/* Location: ./application/controllers/switchports.php */