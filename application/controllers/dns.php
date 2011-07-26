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
		$this->_error("No action specified");
		return;
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
		if(self::$addr->get_dynamic() == FALSE) {
			$navOptions['Firewall Rules'] = "/firewall/view/".self::$addr->get_address();
		}
		
		$navModes['CREATE'] = "/dns/create/".self::$addr->get_address();
		$navModes['EDIT'] = "/dns/edit/".self::$addr->get_address();
		$navModes['DELETE'] = "/dns/delete/".self::$addr->get_address();
		
		// Load view data
		$info['header'] = $this->load->view('core/header',"",TRUE);
		$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
		$viewData['address'] = self::$addr;
		$info['title'] = "DNS - ".self::$addr->get_address();
		$title = "DNS for ".self::$addr->get_address();
		if(self::$addr->get_dynamic() == TRUE) {
			$title = "DNS for Dynamic Address";
		}
		$navbar = new Navbar($title, $navModes, $navOptions);
		
		// More view data
		$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);
		
		$data = $this->_load_records("view");
		$info['data'] = $this->load->view('dns/records', array("data"=>$data), TRUE);

		// Load the main view
		$this->load->view('core/main',$info);
	
	}
	
	private function _load_records($view="view") {
		$viewData = "";
		if(self::$addr->get_address_record()) {
			$viewData .= $this->load->view("dns/$view/a",array("record"=>self::$addr->get_address_record()),TRUE);
		}
		if(self::$addr->get_pointer_records()) {
			$viewData .= $this->load->view("dns/$view/pointer",array("records"=>self::$addr->get_pointer_records()),TRUE);
		}
		if(self::$addr->get_text_records()) {
			$viewData .= $this->load->view("dns/$view/text",array("records"=>self::$addr->get_text_records()),TRUE);
		}
		if(self::$addr->get_ns_records()) {
			$viewData .= $this->load->view("dns/$view/ns",array("records"=>self::$addr->get_ns_records()),TRUE);
		}
		if(self::$addr->get_mx_records()) {
			$viewData .= $this->load->view("dns/$view/mx",array("records"=>self::$addr->get_mx_records()),TRUE);
		}
		
		if($viewData == "") {
			$viewData = $this->load->view("dns/$view/none",null,TRUE);
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
		
			if(self::$addr->get_address_record() == NULL && !preg_match("/^A+$/",$this->input->post('type'))) {
				$this->_error("Need to create an address (A/AAAA) record first!");
				return;
			}
		
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
				$this->_error("Cont: ".$cE->getMessage());
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
	
	public function edit($address=NULL,$type=NULL,$zone=NULL,$hostname=NULL,$alias=NULL) {
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
			if(!$this->input->post('submit')) {
				
				$record = $this->_get_record_obj($address,$type,$zone,$hostname,$alias);
				
				// Navbar
				$navModes['CANCEL'] = "/dns/view/".self::$addr->get_address();
				$navbar = new Navbar("Edit DNS Record", $navModes, null);

				// Load the view data
				$info['header'] = $this->load->view('core/header',"",TRUE);
				$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
				$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);

				// Get the preset form data for drop down lists and things
				$form['addr'] = self::$addr;
				$form['type'] = $type;
				$form['user'] = $this->impulselib->get_username();
				$form['zones'] = $this->api->dns->get_dns_zones($form['user']);
				$form['record'] = $record;

				// Are you an admin?
				if($this->api->isadmin() == TRUE) {
					$form['admin'] = TRUE;
				}

				// Continue loading view data
				$info['data'] = $this->load->view("dns/edit/$type",$form,TRUE);
				$info['title'] = "Edit DNS Address";

				// Load the main view
				$this->load->view('core/main',$info);
			}
			else {
				$record = $this->_get_record_obj($address,$type,$zone,$hostname,$alias);
				$this->_edit($record);
				
				
				// Add it to the address
				#self::$addr->add_record($record);
				self::$addr = $this->api->systems->get_system_interface_address($record->get_address(),true);
				
				// Update our information
				self::$int->add_address(self::$addr);
				self::$sys->add_interface(self::$int);
				$this->impulselib->set_active_system(self::$sys);
				
				redirect(base_url()."/dns/edit/".self::$addr->get_address(),'location');
			}
		}
		else {	
			// Navbar
			$navModes['CANCEL'] = "/dns/view/".self::$addr->get_address();
			$navbar = new Navbar("Edit DNS Record", $navModes, null);

			// Load the view data
			$info['header'] = $this->load->view('core/header',"",TRUE);
			$info['sidebar'] = $this->load->view('core/sidebar',"",TRUE);
			$info['navbar'] = $this->load->view('core/navbar',array("navbar"=>$navbar),TRUE);

			// Get the preset form data for drop down lists and things
			#$form['addr'] = self::$addr;
			#$form['type'] = $this->input->post('type');
			#$form['user'] = $this->impulselib->get_username();
			#$form['address'] = self::$addr;

			// Are you an admin?
			#if($this->api->isadmin() == TRUE) {
			#	$form['admin'] = TRUE;
			#}

			// Continue loading view data
			#$data = $this->_load_records("delete");
			$data = $this->_load_records("edit_select");
			$info['data'] = $this->load->view('dns/records', array("data"=>$data), TRUE);
			$info['title'] = "Edit DNS Address";

			// Load the main view
			$this->load->view('core/main',$info);
		}
	}
	
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
			# Not sure why this was here
			#$type = $this->input->post('type');
			
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
			#$info['data'] = $this->load->view('dns/delete',$form,TRUE);
			$data = $this->_load_records("delete");
			$info['data'] = $this->load->view('dns/records', array("data"=>$data), TRUE);
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
				if(self::$addr->get_dynamic() == TRUE) {
					throw new ControllerException('Cannot add special records to a Dynamic host');
				}
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
				if(self::$addr->get_dynamic() == TRUE) {
					throw new ControllerException('Cannot add special records to a Dynamic host');
				}
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
				if(self::$addr->get_dynamic() == TRUE) {
					throw new ControllerException('Cannot add special records to a Dynamic host');
				}
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
				if(self::$addr->get_dynamic() == TRUE) {
					throw new ControllerException('Cannot add special records to a Dynamic host');
				}
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
					self::$addr->get_address(),
					$this->input->post('hostname'),
					$this->input->post('zone'),
					$ttl,
					$this->input->post('owner')
				);
				return $aRecord;
				break;
			case 'AAAA':
				$aRecord = $this->api->dns->create_dns_address(
					self::$addr->get_address(),
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
	
	private function _edit(&$record) {		
		$err = "";
			
		if($record->get_hostname() != $this->input->post('hostname')) {
			try { $record->set_hostname($this->input->post('hostname')); }
			catch (ObjectException $oE) { $err .= $oE->getMessage(); }
		}
		if($record->get_zone() != $this->input->post('zone')) {
			try { $record->get_zone($this->input->post('zone')); }
			catch (ObjectException $oE) { $err .= $oE->getMessage(); }
		}
		if($record->get_ttl() != $this->input->post('ttl')) {
			try { $record->set_ttl($this->input->post('ttl')); }
			catch (ObjectException $oE) { $err .= $oE->getMessage(); }
		}
		if($record->get_owner() != $this->input->post('owner')) {
			try { $record->set_owner($this->input->post('owner')); }
			catch (ObjectException $oE) { $err .= $oE->getMessage(); }
		}
		
		switch ($record->get_type()) {
			case "A":
				break;
			case "AAAA":
				break;
			case "CNAME":
				if($record->get_alias() != $this->input->post('alias')) {
					try { $record->set_alias($this->input->post('alias')); }
					catch (ObjectException $oE) { $err .= $oE->getMessage(); }
				}
				break;
			case "SRV":
				if($record->get_alias() != $this->input->post('alias')) {
					try { $record->set_alias($this->input->post('alias')); }
					catch (ObjectException $oE) { $err .= $oE->getMessage(); }
				}
				if($record->get_priority() != $this->input->post('priority')) {
					try { $record->set_priority($this->input->post('priority')); }
					catch (ObjectException $oE) { $err .= $oE->getMessage(); }
				}
				if($record->get_weight() != $this->input->post('weight')) {
					try { $record->set_weight($this->input->post('weight')); }
					catch (ObjectException $oE) { $err .= $oE->getMessage(); }
				}
				if($record->get_port() != $this->input->post('port')) {
					try { $record->set_port($this->input->post('port')); }
					catch (ObjectException $oE) { $err .= $oE->getMessage(); }
				}
				break;
			case "TXT":
				if($record->get_text() != $this->input->post('text')) {
					try { $record->set_text($this->input->post('text')); }
					catch (ObjectException $oE) { $err .= $oE->getMessage(); }
				}
				break;
			case "SPF":
				if($record->get_text() != $this->input->post('text')) {
					try { $record->set_text($this->input->post('text')); }
					catch (ObjectException $oE) { $err .= $oE->getMessage(); }
				}
				break;
			case "NS":
				if($record->get_isprimary() != $this->input->post('isprimary')) {
					try { $record->set_isprimary($this->input->post('isprimary')); }
					catch (ObjectException $oE) { $err .= $oE->getMessage(); }
				}
				break;
			case "MX":
				if($record->get_preference() != $this->input->post('preference')) {
					try { $record->set_preference($this->input->post('preference')); }
					catch (ObjectException $oE) { $err .= $oE->getMessage(); }
				}
				break;
			default:
				throw new ControllerException("Could not determine your record type");
		}
		
		if($err != "") {
			throw new ControllerException($err);
		}
	}
	
	private function _delete(&$obj) {}
	
	private function _get_record_obj($address=NULL,$type=NULL,$zone=NULL,$hostname=NULL,$alias=NULL) {
		switch($type) {
			case 'CNAME':
				$record = self::$addr->get_pointer_record($alias, $hostname, $zone);
				break;
			case 'SRV':
				$record = self::$addr->get_pointer_record($alias, $hostname, $zone);
				break;
			case 'TXT':
				$record = self::$addr->get_text_record($hostname, $zone, $type);
				break;
			case 'SPF':
				$record = self::$addr->get_text_record($hostname, $zone, $type);
				break;
			case 'NS':
				$record = self::$addr->get_ns_record($hostname, $zone);
				break;
			case 'MX':
				$record = self::$addr->get_mx_record($hostname, $zone);
				break;
			case 'A':
				$record = self::$addr->get_address_record();
				break;
			case 'AAAA':
				$record = self::$addr->get_address_record();
				break;
			default:
				throw new ControllerException("Unable to determine your type. Make sure you aren't pulling any URL shenanigans.");
		}
		
		return $record;
	}
}

/* End of file dns.php */
/* Location: ./application/controllers/dns.php */