<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "controllers/systems.php");

class Options extends ImpulseController {
	
	public static $dnsKey;
	
	public function __construct() {
		parent::__construct();
	}

    public function view($mode=NULL,$target=NULL) {
        if($mode==NULL) {
            $this->_error("No option type specified for view");
        }
        $target = urldecode($target);

        // Navbar
		$navOptions['Global'] = "/dhcp/options/view/global/";
        $navOptions['Class'] = "/dhcp/options/view/class/";
        $navOptions['Subnet'] = "/dhcp/options/view/subnet/";
        $navOptions['Range'] = "/dhcp/options/view/range/";

		$navModes['EDIT'] = "/dhcp/options/edit/$mode";
		$navModes['DELETE'] = "/dhcp/options/delete/$mode";

		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['title'] = "DHCP ".ucfirst($mode)." Options";
		$navbar = new Navbar("DHCP ".ucfirst($mode)." Options", $navModes, $navOptions);
        $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);

		// More view data
		switch($mode) {
            case "global":
                $viewData = $this->_view_global();
                break;
            case "class":
                $viewData = $this->_view_class($target);
                break;
            case "subnet":
                $viewData = $this->_view_subnet($target);
                break;
            case "range":
                $viewData = $this->_view_range($target);
                break;
            default:
                $this->_error("Invalid view target given");
                break;
        }
		$info['data'] = $viewData;

		// Load the main view
		$this->load->view('core/main',$info);
    }

    private function _view_global() {
        try {
            $options = $this->api->dhcp->get->global_options();
            $viewData = $this->load->view('dhcp/options/view',array("options"=>$options),TRUE);
        }
        catch (ObjectNotFoundException $onfE) {
            $viewData = $this->_warning("No global options configured!");
        }
        catch (DBException $dbE) {
            $this->_error($dbE->getMessage());
        }
        return $viewData;
    }

    private function _view_class($class) {
        if($class=="") {
            $this->_error("No class specified for viewing.");
        }
        try {
            $options = $this->api->dhcp->get->class_options($class);
            $viewData = $this->load->view('dhcp/options/view',array("options"=>$options),TRUE);
        }
        catch (ObjectNotFoundException $onfE) {
            $viewData = $this->_warning("No class options configured!");
        }
        catch (DBException $dbE) {
            $this->_error($dbE->getMessage());
        }
        return $viewData;
    }

    private function _view_subnet($subnet) {
        if($subnet=="") {
            $this->_error("No subnet specified for viewing.");
        }
        try {
            $options = $this->api->dhcp->get->subnet_options($subnet);
            $viewData = $this->load->view('dhcp/options/view',array("options"=>$options),TRUE);
        }
        catch (ObjectNotFoundException $onfE) {
            $viewData = $this->_warning("No global options configured!");
        }
        catch (DBException $dbE) {
            $this->_error($dbE->getMessage());
        }
        return $viewData;
    }

    private function _view_range($range) {
        if($range=="") {
            $this->_error("No range specified for viewing.");
        }
        try {
            $options = $this->api->dhcp->get->range_options($range);
            $viewData = $this->load->view('dhcp/options/view',array("options"=>$options),TRUE);
        }
        catch (ObjectNotFoundException $onfE) {
            $viewData = $this->_warning("No global options configured!");
        }
        catch (DBException $dbE) {
            $this->_error($dbE->getMessage());
        }
        return $viewData;
    }
}
/* End of file options.php */
/* Location: ./application/controllers/dhcp_controllers/options.php */