<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Impulselib {
	function get_eui64_address($mac)
	{
		return $mac;
	}
	
	function get_os_img_path($osname)
	{
		$paths['Arch'] = "media/images/os/Arch.jpg";
		$paths['CentOS'] = "media/images/os/CentOS.jpg";
		$paths['Cisco IOS'] = "media/images/os/Cisco IOS.jpg";
		$paths['Debian'] = "media/images/os/Debian.jpg";
		$paths['Exherbo'] = "media/images/os/Exherbo.jpg";
		$paths['Fedora'] = "media/images/os/Fedora.jpg";
		$paths['FreeBSD'] = "media/images/os/FreeBSD.jpg";
		$paths['Gentoo'] = "media/images/os/Gentoo.jpg";
		$paths['NetBSD'] = "media/images/os/NetBSD.jpg";
		$paths['OpenBSD'] = "media/images/os/OpenBSD.jpg";
		$paths['Slackware'] = "media/images/os/Slackware.jpg";
		$paths['Ubuntu'] = "media/images/os/Ubuntu.jpg";
		$paths['Windows 7'] = "media/images/os/Windows7.jpg";
		$paths['Windows Server 2003'] = "media/images/os/WindowsServer2003.jpg";
		$paths['Windows Server 2008'] = "media/images/os/WindowsServer2008.jpg";
		$paths['Windows Server 2008 R2'] = "media/images/os/WindowsServer2008R2.jpg";
		$paths['Windows Vista'] = "media/images/os/WindowsVista.jpg";
		$paths['Windows XP'] = "media/images/os/WindowsXP.jpg";

		return $paths[$osname];
	}
}

class System {

	// Information to describe the system
	private $system_name;
	private $owner;
	private $comment;
	private $date_created;
	private $date_modified;
	private $last_modifier;
	private $renew_date;
	private $type;
	private $os_name;
	
	// Interface Information
	private $interfaces;
	
	// The CI outside world
	private $CI;
	
	
	function __construct($input_name)
	{
		// Load in the CI world so we can access other libraries and things
		$CI =& get_instance();
		
		// Get and populate system information
		$info = $CI->api->get_system_info($input_name);
		$this->system_name = $info['system_name'];
		$this->owner = $info['owner'];
		$this->comment = $info['comment'];
		$this->date_created = $info['date_created'];
		$this->date_modified = $info['date_modified'];
		$this->last_modifier = $info['last_modifier'];
		$this->renew_date = $info['renew_date'];
		$this->type = $info['type'];
		$this->os_name = $info['os_name'];
		
		// Load interface information
		$interface_info = $CI->api->get_system_interfaces($this->system_name);
		foreach ($interface_info as $interface)
		{
			$this->interfaces[$interface['name']] = new NetworkInterface($interface);
		}
	}
	
	// Accessors for system properties
    function get_system_name()
    {
		return $this->system_name;
    }
	
	function get_owner()
	{
		return $this->owner;
	}
	
	function get_comment()
	{
		return $this->comment;
	}
	
	function get_date_created()
	{
		return $this->date_created;
	}
	
	function get_date_modified()
	{
		return $this->date_modified;
	}
	
	function get_last_modifier()
	{
		return $this->last_modifier;
	}
	
	function get_renew_date()
	{
		return $this->renew_date;
	}
	
	function get_type()
	{
		return $this->type;
	}
	
	function get_os_name()
	{
		return $this->os_name;
	}
	
	function get_interfaces()
	{
		return $this->interfaces;
	}
}

class NetworkInterface {
	private $mac;
	private $comment;
	private $date_created;
	private $date_modified;
	private $last_modifier;
	private $system_name;
	private $name;
	
	private $addresses;
	
	// The CI outside world
	private $CI;
	
	function __construct($info)
	{
		$CI =& get_instance();
		$this->mac = $info['mac'];
		$this->comment = $info['comment'];
		$this->date_created = $info['date_created'];
		$this->date_modified = $info['date_modified'];
		$this->last_modifier = $info['last_modifier'];
		$this->system_name = $info['system_name'];
		$this->name = $info['name'];
		
		$address_info = $CI->api->get_interface_addresses($this->mac);
		foreach ($address_info as $address)
		{
			$this->addresses[$address['address']] = new InterfaceAddress($address);
		}
	}
	
	function get_name()
	{
		return $this->name;
	}
	
	function get_mac()
	{
		return $this->mac;
	}
	
	function get_comment()
	{
		return $this->comment;
	}
	
	function get_date_created()
	{
		return $this->date_created;
	}
	
	function get_date_modified()
	{
		return $this->date_modified;
	}
	
	function get_last_modifier()
	{
		return $this->last_modifier;
	}
	
	function get_system_name()
    {
		return $this->system_name;
    }
	
	function get_interface_addresses()
	{
		return $this->addresses;
	}
}

class InterfaceAddress {
	private $date_created;
	private $date_modified;
	private $last_modifier;
	private $address;
	private $mac;
	private $isprimary;
	private $config;
	private $class;
	private $comment;
	
	// DNS
	private $fqdn;
	
	// Firewall
	private $rules = array();
	
	// The CI outside world
	private $CI;
	
	function __construct($info)
	{
		$CI =& get_instance();
		$this->date_created = $info['date_created'];
		$this->date_modified = $info['date_modified'];
		$this->last_modifier = $info['last_modifier'];
		$this->address = $info['address'];
		$this->mac = $info['mac'];
		$this->isprimary = $info['isprimary'];
		$this->config = $info['config'];
		$this->class = $info['class'];
		$this->comment = $info['comment'];
		
		$this->fqdn = $CI->api->get_ip_fqdn($this->address);
		
		$rules_info = $CI->api->get_address_rules($this->address);
		foreach ($rules_info as $rule_info) {
			$rule = new FirewallRule($rule_info);
			array_push($this->rules, $rule);
		}
	}
	
	function get_date_created()
	{
		return $this->date_created;
	}
	
	function get_date_modified()
	{
		return $this->date_modified;
	}
	
	function get_last_modifier()
	{
		return $this->last_modifier;
	}
	
	function get_address()
	{
		return $this->address;
	}
	
	function get_mac()
	{
		return $this->interface;
	}
	
	function get_isprimary()
	{
		return $this->isprimary;
	}
	
	function get_config()
	{
		return $this->config;
	}
	
	function get_class()
	{
		return $this->class;
	}
	
	function get_fqdn()
	{
		return $this->fqdn;
	}
	
	function get_comment()
	{
		return $this->comment;
	}
	
	function get_rules()
	{
		return $this->rules;
	}
}

class FirewallRule {
	private $port;
	private $transport;
	private $deny;
	private $comment;
	private $address;
	private $date_created;
	private $date_modified;
	private $last_modifier;
	private $owner;
	private $source;
	
	function __construct($info)
	{
		$CI =& get_instance();
		$this->port = $info['port'];
		$this->transport = $info['transport'];
		$this->deny = $info['deny'];
		$this->comment = $info['comment'];
		$this->address = $info['address'];
		$this->date_created = $info['date_created'];
		$this->date_modified = $info['date_modified'];
		$this->last_modifier = $info['last_modifier'];
		$this->owner = $info['owner'];
		$this->source = $info['source'];
	}
	
	function get_port() {
		return $this->port;
	}
	
	function get_transport() {
		return $this->transport;
	}
	
	function get_deny() {
		return $this->deny;
	}
	
	function get_owner() {
		return $this->owner;
	}
	
	function get_source() {
		return $this->source;
	}
	
	function get_comment()
	{
		return $this->comment;
	}
	
	function get_date_created()
	{
		return $this->date_created;
	}
	
	function get_date_modified()
	{
		return $this->date_modified;
	}
	
	function get_last_modifier()
	{
		return $this->last_modifier;
	}
	
	function get_address()
	{
		return $this->address;
	}
}

/* End of file System.php */