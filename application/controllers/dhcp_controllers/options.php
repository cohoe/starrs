<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "controllers/systems.php");

class Options extends ImpulseController {
	
	public static $dnsKey;
	
	public function __construct() {
		parent::__construct();
	}

    public function view($target=NULL) {
        if($target==NULL) {
            $this->_error("No option type specified for view");
        }

        // Navbar
		$navOptions['Global'] = "/dhcp/options/view/global/";
        $navOptions['Class'] = "/dhcp/options/view/class/";
        $navOptions['Subnet'] = "/dhcp/options/view/subnet/";
        $navOptions['Range'] = "/dhcp/options/view/range/";

		$navModes['EDIT'] = "/dhcp/options/edit/$target";
		$navModes['DELETE'] = "/dhcp/options/delete/$target";

		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$info['title'] = "DHCP ".ucfirst($target)." Options";
		$navbar = new Navbar("DHCP ".ucfirst($target)." Options", $navModes, $navOptions);
        $info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);

		// More view data
		switch($target) {
            case "global":
                $viewData = $this->_view_global();
                break;
            case "class":
                $viewData = $this->_view_class();
                break;
            case "subnet":
                $viewData = $this->_view_subnet();
                break;
            case "range":
                $viewData = $this->_view_range();
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
            $viewData = $this->load->view('dhcp/options/view_global',array("options"=>$options),TRUE);
        }
        catch (ObjectNotFoundException $onfE) {
            $viewData = $this->_warning("No global options configured!");
        }
        catch (DBException $dbE) {
            $this->_error($dbE->getMessage());
        }
        return $viewData;
    }

    private function _view_class() {
        $viewData = "Class";
        return $viewData;
    }

    private function _view_subnet() {
        $viewData = "Subnet";
        return $viewData;
    }

    private function _view_range() {
        $viewData = "Range";
        return $viewData;
    }
}
/* End of file options.php */
/* Location: ./application/controllers/dhcp_controllers/options.php */