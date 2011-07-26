<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');



class ImpulseLoader {
	public function initialize() {

		# Core
		require_once(APPPATH . "libraries/core/ImpulseObject.php");
		
		# Objects
		require_once(APPPATH . "libraries/objects/DnsRecord.php");
		require_once(APPPATH . "libraries/objects/AddressRecord.php");
		require_once(APPPATH . "libraries/objects/FirewallRule.php");
		require_once(APPPATH . "libraries/objects/InterfaceAddress.php");
		require_once(APPPATH . "libraries/objects/MxRecord.php");
		require_once(APPPATH . "libraries/objects/NetworkInterface.php");
		require_once(APPPATH . "libraries/objects/NsRecord.php");
		require_once(APPPATH . "libraries/objects/PointerRecord.php");
		require_once(APPPATH . "libraries/objects/System.php");
		require_once(APPPATH . "libraries/objects/TextRecord.php");
		require_once(APPPATH . "libraries/objects/ConfigType.php");
		require_once(APPPATH . "libraries/objects/ConfigClass.php");
        require_once(APPPATH . "libraries/objects/IpRange.php");
        require_once(APPPATH . "libraries/objects/FirewallProgram.php");
		
		# Exceptions
		require_once(APPPATH . "libraries/exceptions/ControllerException.php");
		require_once(APPPATH . "libraries/exceptions/ObjectException.php");
		require_once(APPPATH . "libraries/exceptions/AmbiguousTargetException.php");
		require_once(APPPATH . "libraries/exceptions/DBException.php");
		require_once(APPPATH . "libraries/exceptions/ObjectNotFoundException.php");
		require_once(APPPATH . "libraries/exceptions/APIException.php");
		
		# UI Stuff
		require_once(APPPATH . "libraries/core/navbar.php");
	}
}
