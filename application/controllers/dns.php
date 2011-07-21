<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "controllers/systems.php");
require_once(APPPATH . "libraries/core/ImpulseController.php");
/**
 * 
 */
class Dns extends ImpulseController {
	
	public function __construct() {
		parent::__construct();
	}
	
	public function index() {
		
	}
	
	public function view($address=NULL) {
	
		if($address==NULL) {
			$this->_error("No address specified");
			return;
		}
		if(!(self::$sys instanceof System)) {
			$this->_load_system();
		}
		if(!(self::$addr instanceof InterfaceAddress)) {
			$this->_load_address($address);
		}

		// Navbar
		$navOptions['Overview'] = "/addresses/view/".self::$addr->get_address();
		$navOptions['DNS Records'] = "/dns/view/".self::$addr->get_address();
		$navOptions['Firewall Rules'] = "/firewall/view/".self::$addr->get_address();
		
		$navModes['CREATE'] = "/dns/create/".self::$addr->get_address();
		$navModes['DELETE'] = "/dns/delete/".self::$addr->get_address();
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$viewData['address'] = self::$addr;
		$info['title'] = "DNS - ".self::$addr->get_address();
		$navbar = new Navbar("DNS for ".self::$addr->get_address(), $navModes, $navOptions);
		
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		
		$data = $this->_load_records();
		$info['data'] = $this->load->view('dns/records', array("data"=>$data), TRUE);

		// Load the main view
		$this->load->view('core/main',$info);
	
	}
	
	private function _load_records() {
		$viewData = "";
		if(self::$addr->get_address_record()) {
			$viewData .= $this->load->view('dns/records/a',array("record"=>self::$addr->get_address_record()),TRUE);
		}
		if(self::$addr->get_pointer_records()) {
			$viewData .= $this->load->view('dns/records/pointer',array("records"=>self::$addr->get_pointer_records()),TRUE);
		}
		if(self::$addr->get_text_records()) {
			$viewData .= $this->load->view('dns/records/text',array("records"=>self::$addr->get_text_records()),TRUE);
		}
		if(self::$addr->get_ns_records()) {
			$viewData .= $this->load->view('dns/records/ns',array("records"=>self::$addr->get_ns_records()),TRUE);
		}
		if(self::$addr->get_mx_records()) {
			$viewData .= $this->load->view('dns/records/mx',array("records"=>self::$addr->get_mx_records()),TRUE);
		}
		
		if($viewData == "") {
			$viewData = $this->load->view('dns/records/none',null,TRUE);
		}
		
		return $viewData;
	}
	
	public function create($address) {
	
		if($address==NULL) {
			$this->_error("No address specified");
			return;
		}
		if(!(self::$sys instanceof System)) {
			$this->_load_system();
		}
		if(!(self::$addr instanceof InterfaceAddress)) {
			$this->_load_address($address);
		}
		
		if($this->input->post('typeSubmit')) {
			// Navbar
			$navModes['CANCEL'] = "/dns/view/".self::$addr->get_address();
			$navbar = new Navbar("Create DNS Record", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);

			// Get the preset form data for drop down lists and things
			$form['addr'] = self::$addr;
			$form['type'] = $this->input->post('type');
			$form['user'] = $this->impulselib->get_username();
			$form['zones'] = $this->api->dns->get_dns_zones($form['user']);

			// Are you an admin?
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}

			// Continue loading view data
			$info['data'] = $this->load->view('dns/create',$form,TRUE);
			$info['title'] = "Create DNS Address";

			// Load the main view
			$this->load->view('core/main',$info);
		}
		elseif($this->input->post('recordSubmit')) {
			// Create the record
			try {
				$record = $this->_create();
			}
			catch (DBException $dbE) {
				$this->_error("DB: ".$dbE->getMessage());
				return;
			}
			catch (ObjectException $oE) {
				$this->_error("Obj: ".$dbE->getMessage());
				return;
			}
			catch (ControllerException $cE) {
				$this->_error("Cont: ".$dbE->getMessage());
				return;
			}
			
			// Add it to the address
			self::$addr->add_record($record);
			
			// Update our information
			self::$int->add_address(self::$addr);
			self::$sys->add_interface(self::$int);
			$this->impulselib->set_active_system(self::$sys);
			
			// Move along
			redirect(base_url()."/dns/view/".self::$addr->get_address(),'location');
		}
		else {
			// Navbar
			$navModes['CANCEL'] = "/dns/view/".self::$addr->get_address();
			$navbar = new Navbar("Create DNS Record", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);

			// Get the preset form data for drop down lists and things
			$form['address'] = self::$addr;
			$form['types'] = $this->api->dns->get_record_types();

			// Are you an admin?
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}

			// Continue loading view data
			$info['data'] = $this->load->view('dns/typeselect',$form,TRUE);
			$info['title'] = "Create DNS Address";

			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	public function edit($obj) {}
	
	public function delete($address=NULL,$type=NULL,$zone=NULL,$hostname=NULL,$alias=NULL) {
		// Check to make sure the user didnt forget anything
		if($address==NULL) {
			$this->_error("No address specified");
			return;
		}
		if(!(self::$sys instanceof System)) {
			$this->_load_system();
		}
		if(!(self::$addr instanceof InterfaceAddress)) {
			$this->_load_address($address);
		}
		
		// A given type indicates that we are doing something
		if($type != NULL) {
		
			// TYPE		HOSTNAME	ZONE	ALIAS
			// ---------------------------------
			// A/AAAA	hostname	zone	x
			// CNAME	hostname	zone	alias
			// SRV		hostname	zone	alias
			// TXT		hostname	zone	x
			// SPF		hostname	zone	x
			// NS		hostname	zone	x
			// MX		hostname	zone	x
		
			switch($type) {
				case 'CNAME':
					$this->api->dns->remove_dns_cname($alias, $hostname, $zone);
					break;
				case 'SRV':
					$this->api->dns->remove_dns_srv($alias, $hostname, $zone);
					break;
				case 'TXT':
					$this->api->dns->remove_dns_text($hostname, $zone, $type);
					break;
				case 'SPF':
					$this->api->dns->remove_dns_text($hostname, $zone, $type);
					break;
				case 'NS':
					$this->api->dns->remove_dns_nameserver($hostname, $zone);
					break;
				case 'MX':
					$this->api->dns->remove_dns_mailserver($hostname, $zone);
					break;
				case 'A':
					$this->api->dns->remove_dns_address($address);
					break;
				case 'AAAA':
					$this->api->dns->remove_dns_address($address);
					break;
				default:
					$this->_error("Unable to determine your type. Make sure you aren't pulling any URL shenanigans.");
					return;
			}
			
			// Set the SESSION data
			self::$int->add_address($this->api->systems->get_system_interface_address($address,true));
			self::$sys->add_interface(self::$int);
			$this->impulselib->set_active_system(self::$sys);
			
			// Move along
			redirect(base_url()."/dns/delete/".self::$addr->get_address(),'location');
		}
		
		else {
			$type = $this->input->post('type');
			
			// Navbar
			$navModes['CANCEL'] = "/dns/view/".self::$addr->get_address();
			$navbar = new Navbar("Delete DNS Record", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);

			// Get the preset form data for drop down lists and things
			$form['addr'] = self::$addr;
			$form['type'] = $this->input->post('type');
			$form['user'] = $this->impulselib->get_username();
			$form['address'] = self::$addr;

			// Are you an admin?
			if($this->api->isadmin() == TRUE) {
				$form['admin'] = TRUE;
			}

			// Continue loading view data
			$info['data'] = $this->load->view('dns/delete',$form,TRUE);
			$info['title'] = "Delete DNS Address";

			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
	private function _create() {
		if(!$this->input->post('ttl')) {
			$ttl = NULL;
		}
		else {
			$ttl = $this->input->post('ttl');
		}
		
		$type = $this->input->post('type');
		
		// Call the create function
		switch($type) {
			case 'CNAME':
				$pointerRecord = $this->api->dns->create_dns_cname(
					$this->input->post('alias'),
					$this->input->post('hostname'),
					$this->input->post('zone'),
					$ttl,
					$this->input->post('owner')
				);
				return $pointerRecord;
				break;
			case 'SRV':
				$pointerRecord = $this->api->dns->create_dns_srv(
					$this->input->post('alias'),
					$this->input->post('hostname'),
					$this->input->post('zone'),
					$this->input->post('priority'),
					$this->input->post('weight'),
					$this->input->post('port'),
					$ttl,
					$this->input->post('owner')
				);
				return $pointerRecord;
				break;
			case 'TXT':
				$textRecord = $this->api->dns->create_dns_text(
					$this->input->post('hostname'),
					$this->input->post('zone'),
					$this->input->post('text'),
					$this->input->post('type'),
					$ttl,
					$this->input->post('owner')
				);
				return $textRecord;
				break;
			case 'SPF':
				$textRecord = $this->api->dns->create_dns_text(
					$this->input->post('hostname'),
					$this->input->post('zone'),
					$this->input->post('text'),
					$this->input->post('type'),
					$ttl,
					$this->input->post('owner')
				);
				return $textRecord;
				break;
			case 'NS':
				$nsRecord = $this->api->dns->create_dns_nameserver(
					$this->input->post('hostname'),
					$this->input->post('zone'),
					$this->input->post('isprimary'),
					$ttl,
					$this->input->post('owner')
				);
				return $nsRecord;
				break;
			case 'MX':
				$mxRecord = $this->api->dns->create_dns_mailserver(
					$this->input->post('hostname'),
					$this->input->post('zone'),
					$this->input->post('preference'),
					$ttl,
					$this->input->post('owner')
				);
				return $mxRecord;
				break;
			case 'A':
				$aRecord = $this->api->dns->create_dns_address(
					$this->input->post('address'),
					$this->input->post('hostname'),
					$this->input->post('zone'),
					$ttl,
					$this->input->post('owner')
				);
				return $aRecord;
				break;
			case 'AAAA':
				$aRecord = $this->api->dns->create_dns_address(
					$this->input->post('address'),
					$this->input->post('hostname'),
					$this->input->post('zone'),
					$ttl,
					$this->input->post('owner')
				);
				return $aRecord;
				break;
			default:
				throw new ControllerException("Unable to determine your type. Make sure you aren't pulling any URL shenanigans.");
		}
	}
	
	private function _edit(&$obj) {}
	
	private function _delete(&$obj) {}
}

/* End of file dns.php */
/* Location: ./application/controllers/dns.php */
