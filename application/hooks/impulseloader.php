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
		require_once(APPPATH . "libraries/objects/Metahost.php");
		require_once(APPPATH . "libraries/objects/MetahostMember.php");
		require_once(APPPATH . "libraries/objects/MetahostRule.php");
		require_once(APPPATH . "libraries/objects/MetahostProgram.php");
		require_once(APPPATH . "libraries/objects/StandaloneRule.php");
		require_once(APPPATH . "libraries/objects/StandaloneProgram.php");
		require_once(APPPATH . "libraries/objects/Subnet.php");
		require_once(APPPATH . "libraries/objects/DnsZone.php");
		require_once(APPPATH . "libraries/objects/DnsKey.php");
		require_once(APPPATH . "libraries/objects/IpAddress.php");
		require_once(APPPATH . "libraries/objects/DhcpOption.php");
		require_once(APPPATH . "libraries/objects/GlobalOption.php");
		require_once(APPPATH . "libraries/objects/ClassOption.php");
		require_once(APPPATH . "libraries/objects/RangeOption.php");
		require_once(APPPATH . "libraries/objects/SubnetOption.php");
		require_once(APPPATH . "libraries/objects/DhcpClass.php");
		require_once(APPPATH . "libraries/objects/NetworkSwitchport.php");
        require_once(APPPATH . "libraries/objects/NetworkSystem.php");
		
		# Exceptions
		require_once(APPPATH . "libraries/exceptions/ControllerException.php");
		require_once(APPPATH . "libraries/exceptions/ObjectException.php");
		require_once(APPPATH . "libraries/exceptions/AmbiguousTargetException.php");
		require_once(APPPATH . "libraries/exceptions/DBException.php");
		require_once(APPPATH . "libraries/exceptions/ObjectNotFoundException.php");
		require_once(APPPATH . "libraries/exceptions/APIException.php");
		
		# UI Stuff
		require_once(APPPATH . "libraries/core/navbar.php");
		require_once(APPPATH . "libraries/core/sidebar.php");
		require_once(APPPATH . "libraries/core/navitem.php");
		
		# Controllers
		#require_once(APPPATH . "controllers/firewall/rule.php");
		#require_once(APPPATH . "controllers/firewall/rules.php");
        
	}
}