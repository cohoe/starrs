<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "libraries/core/ImpulseController.php");

class Options extends ImpulseController {
	
	public function __construct() {
		parent::__construct();
	}
	
	public function index() {
		// Navbar
		$navOptions['DHCP'] = "/dhcp";
		$navbar = new Navbar("DHCP Options", null, $navOptions);
	
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "DHCP Options";
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $this->load->view('dhcp/index',null,TRUE);

		// Load the main view
		$this->load->view('core/main',$info);
	}

    public function view($mode=NULL,$target=NULL) {
        if($mode==NULL) {
            $this->_error("No option type specified for view");
        }
        $target = urldecode($target);
	
		$navModes['CREATE'] = "/dhcp/options/create/$mode/".rawurlencode($target);
		$navModes['EDIT'] = "/dhcp/options/edit/$mode/".rawurlencode($target);
		$navModes['DELETE'] = "/dhcp/options/delete/$mode/".rawurlencode($target);

		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
		$info['title'] = "DHCP ".ucfirst($mode)." Options";

		// More view data
		$navOptions['DHCP'] = "/dhcp";
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
		$navbar = new Navbar("DHCP ".ucfirst($mode)." Options - ".$target, $navModes, $navOptions);
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		$info['data'] = $viewData;

		// Load the main view
		$this->load->view('core/main',$info);
    }
	
	public function create($mode=NULL,$target=NULL) {
		if($mode==NULL) {
            $this->_error("No option type specified for create");
        }
		if($target==NULL && $mode != "global") {
			$this->_error("No target object specified for create");
		}
		
		if($this->input->post('submit')) {
			$this->_create($mode, urldecode($target));
			self::$sidebar->reload();
			redirect(base_url()."dhcp/options/view/$mode/$target",'location');
		}
		else {
			$navModes['CANCEL'] = "/dhcp/options/view/$mode/".rawurlencode($target);
			
			// Load view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['title'] = "Create DHCP Option";
			
			// More view data
			switch($mode) {
				case "global":
					$viewData = $this->load->view('dhcp/options/create',NULL,TRUE);
					break;
				case "class":
					$viewData = $this->load->view('dhcp/options/create',NULL,TRUE);
					break;
				case "subnet":
					$viewData = $this->load->view('dhcp/options/create',NULL,TRUE);
					break;
				case "range":
					$viewData = $this->load->view('dhcp/options/create',NULL,TRUE);
					break;
				default:
					$this->_error("Invalid view target given");
					break;
			}
			$navbar = new Navbar("Create DHCP ".ucfirst($mode)." Option", $navModes, null);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $viewData;

			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	public function delete($mode=NULL,$target=NULL,$option=NULL,$value=NULL) {
		if($mode==NULL) {
            $this->_error("No option type specified for delete");
        }
		if($target==NULL && $mode != "global") {
			$this->_error("No target object specified for delete");
		}
		
		if($option && $value) {
			$option = urldecode($option);
			$value = urldecode($value);
			try {
				$target = urldecode($target);
				switch($mode) {
					case "global":
						$options = $this->api->dhcp->remove->global_option($option,$value);
						break;
					case "class":
						$options = $this->api->dhcp->remove->class_option($target,$option,$value);
						break;
					case "subnet":
						$options = $this->api->dhcp->remove->subnet_option($target,$option,$value);
						break;
					case "range":
						$options = $this->api->dhcp->remove->range_option($target,$option,$value);
						break;
					default:
						$this->_error("Invalid view target given");
						break;
				}
				
				self::$sidebar->reload();
				redirect(base_url()."dhcp/options/view/$mode/".rawurlencode($target),'location');
			}
			catch (DBException $dbE) {
				$this->_error($dbE->getMessage());
			}
		}
		else {
			$navModes['CANCEL'] = "/dhcp/options/view/$mode/".rawurlencode($target);
			
			// Load view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['title'] = "Delete DHCP Option";
			
			// More view data
			$target = urldecode($target);
			try {
				switch($mode) {
					case "global":
						$options = $this->api->dhcp->get->global_options();
						break;
					case "class":
						$options = $this->api->dhcp->get->class_options($target);
						break;
					case "subnet":
						$options = $this->api->dhcp->get->subnet_options($target);
						break;
					case "range":
						$options = $this->api->dhcp->get->range_options($target);
						break;
					default:
						$this->_error("Invalid view target given");
						break;
				}
				$viewData = $this->load->view('dhcp/options/delete',array("options"=>$options,"mode"=>$mode,"target"=>$target),TRUE);
			}
			catch (ObjectNotFoundException $onfE) {
				$viewData = $this->_warning("No options configured on this $mode!");
			}
			$navbar = new Navbar("Delete DHCP ".ucfirst($mode)." Option", $navModes, null);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $viewData;

			// Load the main view
			$this->load->view('core/main',$info);
		}
	}

	public function edit($mode=NULL,$target=NULL,$option=NULL,$value=NULL) {
		if($mode==NULL) {
            $this->_error("No option type specified for edit");
        }
		if($target==NULL && $mode != "global") {
			$this->_error("No target object specified for edit");
		}
		
		$option = html_entity_decode(rawurldecode($option));
		$value = html_entity_decode(rawurldecode($value));
		$target = html_entity_decode(rawurldecode($target));
			
		if($this->input->post('submit')) {
			if($this->input->post('option') != $option) {
				try {
					switch($mode) {
						case "global":
							$this->api->dhcp->modify->global_option($option,$value,'option',$this->input->post('option'));
							break;
						case "class":
							$this->api->dhcp->modify->class_option($target,$option,$value,'option',$this->input->post('option'));
							break;
						case "subnet":
							$this->api->dhcp->modify->subnet_option($target,$option,$value,'option',$this->input->post('option'));
							break;
						case "range":
							$this->api->dhcp->modify->range_options($target,$option,$value,'option',$this->input->post('option'));
							break;
						default:
							$this->_error("Invalid edit mode given");
							break;
					}
					$option = $this->input->post('option');
				}
				catch(Exception $e) {
					$this->_error($e->getMessage());
				}
			}
			if($this->input->post('value') != $value) {
				try {
					switch($mode) {
						case "global":
							$this->api->dhcp->modify->global_option($option,$value,'value',$this->input->post('value'));
							break;
						case "class":
							$this->api->dhcp->modify->class_option($target,$option,$value,'value',$this->input->post('value'));
							break;
						case "subnet":
							$this->api->dhcp->modify->subnet_option($target,$option,$value,'value',$this->input->post('value'));
							break;
						case "range":
							$this->api->dhcp->modify->range_options($target,$option,$value,'value',$this->input->post('value'));
							break;
						default:
							$this->_error("Invalid edit mode given");
							break;
					}
					$value = $this->input->post('value');
					self::$sidebar->reload();
					redirect(base_url()."dhcp/options/view/$mode/".rawurlencode($target),'location');
				}
				catch(Exception $e) {
					$this->_error($e->getMessage());
				}
			}
			
		}
		elseif ($option && $value) {
			$option = urldecode($option);
			$value = urldecode($value);
			
			// Navbar
			$navModes['CANCEL'] = "/dhcp/options/view/$mode/".rawurlencode($target);
			$navbar = new Navbar("Edit DHCP ".ucfirst($mode)." Option", $navModes, null);
			
			// Load view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['title'] = "Edit DHCP Option";
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $this->load->view('dhcp/options/edit_single',array("option"=>$option,"value"=>$value),TRUE);

			// Load the main view
			$this->load->view('core/main',$info);
		}
		
		else {
			$navModes['CANCEL'] = "/dhcp/options/view/$mode/".rawurlencode($target);
			
			// Load view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',array("sidebar"=>self::$sidebar),TRUE);
			$info['title'] = "Edit DHCP Option";
			
			// More view data
			$target = urldecode($target);
			try {
				switch($mode) {
					case "global":
						$options = $this->api->dhcp->get->global_options();
						break;
					case "class":
						$options = $this->api->dhcp->get->class_options($target);
						break;
					case "subnet":
						$options = $this->api->dhcp->get->subnet_options($target);
						break;
					case "range":
						$options = $this->api->dhcp->get->range_options($target);
						break;
					default:
						$this->_error("Invalid view target given");
						break;
				}
				$viewData = $this->load->view('dhcp/options/edit',array("options"=>$options,"mode"=>$mode,"target"=>$target),TRUE);
			}
			catch (ObjectNotFoundException $onfE) {
				$viewData = $this->_warning("No options configured on this $mode!");
			}
			$navbar = new Navbar("Edit DHCP ".ucfirst($mode)." Option", $navModes, null);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
			$info['data'] = $viewData;

			// Load the main view
			$this->load->view('core/main',$info);
		}
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
            $viewData = $this->_warning("No subnet options configured!");
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
            $viewData = $this->_warning("No range options configured!");
        }
        catch (DBException $dbE) {
            $this->_error($dbE->getMessage());
        }
        return $viewData;
    }

	private function _create($mode, $target) {
		try {
			switch($mode) {
				case "global":
					$this->api->dhcp->create->global_option($this->input->post('option'),$this->input->post('value'));
					break;
				case "class":
					$this->api->dhcp->create->class_option($target,$this->input->post('option'),$this->input->post('value'));
					break;
				case "subnet":
					$this->api->dhcp->create->subnet_option($target,$this->input->post('option'),$this->input->post('value'));
					break;
				case "range":
					$this->api->dhcp->create->range_option($target,$this->input->post('option'),$this->input->post('value'));
					break;
				default:
					$this->_error("Invalid view target given");
					break;
			}
		}
		catch (DBException $dbE) {
			$this->_error($dbE->getMessage());
		}
	}
	
}
/* End of file options.php */
/* Location: ./application/controllers/dhcp_controllers/options.php */