<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
require_once(APPPATH . "controllers/welcome.php");

class Sidebar {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	private $ownedSystems;
	private $interfaces;
	private $addresses;
	private $CI;
	private $allSystems;
	private $ownedMetahosts;
	private $otherMetahosts;
	private $ownedKeys;
	private $otherKeys;
	private $ownedZones;
	private $otherZones;
	private $ownedSubnets;
	private $otherSubnets;
	private $ranges;
	private $classes;
	private $netSystems;
	
	private static $rwSystemImageUrl = "/media/images/sidebar/system.png";
	private static $roSystemImageUrl = "/media/images/sidebar/system.png";
	private static $xxSystemImageUrl = "http://sub.obive.net/down.png";
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	public function __construct() {
		$this->CI =& get_instance();
		$currentUser = $this->CI->api->get->current_user();
		try {
			$this->ownedSystems = $this->CI->api->systems->list->owned_systems($currentUser);
			foreach($this->ownedSystems as $system) {
				try {
					$this->_load_system_data($system);
				}
				catch(ObjectNotFoundException $onfE) {}
			}
		}
		catch(ObjectNotFoundException $onfE) {}
		try {	
			$this->allSystems = $this->CI->api->systems->list->other_systems($currentUser);
			foreach($this->allSystems as $system) {
				try {
					try {
						$this->_load_system_data($system);
					}
					catch(ObjectNotFoundException $onfE) {}
				}
				catch(ObjectNotFoundException $onfE) {}
			}
		}
		catch(ObjectNotFoundException $onfE) {}

		try {
			$this->ownedMetahosts = $this->CI->api->firewall->list->owned_metahosts($currentUser);
		}
		catch(ObjectNotFoundException $onfE) {}
		try {
			$this->otherMetahosts = $this->CI->api->firewall->list->other_metahosts($currentUser);
		}
		catch(ObjectNotFoundException $onfE) {}
		
		try {
			$this->ownedKeys = $this->CI->api->dns->list->owned_keys($currentUser);
		}
		catch(ObjectNotFoundException $onfE) {}
		try {	
			$this->otherKeys = $this->CI->api->dns->list->other_keys($currentUser);
		}
		catch(ObjectNotFoundException $onfE) {}
		
		try {
			$this->ownedZones = $this->CI->api->dns->list->owned_zones($currentUser);
		}
		catch(ObjectNotFoundException $onfE) {}
		try {	
			$this->otherZones = $this->CI->api->dns->list->other_zones($currentUser);
		}
		catch(ObjectNotFoundException $onfE) {}
		
		try {
			$this->ownedSubnets = $this->CI->api->ip->list->owned_subnets($currentUser);
		}
		catch(ObjectNotFoundException $onfE) {}
		try {	
			$this->otherSubnets = $this->CI->api->ip->list->other_subnets($currentUser);
		}
		catch(ObjectNotFoundException $onfE) {}
		
		try {	
			$this->ranges = $this->CI->api->ip->list->ranges();
		}
		catch(ObjectNotFoundException $onfE) {}
		
		try {
			$this->classes = $this->CI->api->dhcp->list->classes();
		}
		catch(ObjectNotFoundException $onfE) {}

		try {
			$this->netSystems = $this->CI->api->network->list->systems();
		}
		catch(ObjectNotFoundException $onfE) {}
		
		#print_r($this->interfaces);
	}
	
	//////////////////////////////////////////////////////////////////////
	/// GETTERS
	
	public function get_nav_headings()  { return $this->navHeadings; }
	
	public function get_interfaces($systemName=NULL) { 
		if(isset($this->interfaces[$systemName])) { 
			return $this->interfaces[$systemName]; 
		}
		return null;
	}
	
	public function get_interface_addresses($mac=NULL)  { return $this->addresses[$mac]; }
	
	//////////////////////////////////////////////////////////////////////
	/// SETTERS
	
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
	
	private function _load_system_data($system) {
		#echo "$system\n";
		$this->interfaces[$system] = $this->CI->api->systems->list->interfaces($system);
		foreach($this->interfaces[$system] as $interface) {
			$this->addresses[$interface] = $this->CI->api->systems->list->interface_addresses($interface);
		}
	}
	
	private function _load_address_view_data($address,$last=NULL) {
	
		if($this->CI->api->ip->is_dynamic($address) == 't') {
			return '<li class="expandable '.$last.'"><div class="hitarea expandable-hitarea"></div><img src="/media/images/sidebar/ipaddr.png" /> <a href="/address/view/'.rawurlencode($address).'">Dynamic</a>
				<ul style="display: none;">
					<li class="last"><img src="/media/images/sidebar/dns.png" /> <a href="/dns/view/'.rawurlencode($address).'">DNS Records</a></li>
				</ul>
			</li>';
		}
		else {
			return '<li class="expandable '.$last.'"><div class="hitarea expandable-hitarea"></div><img src="/media/images/sidebar/ipaddr.png" /> <a href="/address/view/'.rawurlencode($address).'">'.$address.'</a>
						<ul style="display: none;">
							<li><img src="/media/images/sidebar/dns.png" /> <a href="/dns/view/'.rawurlencode($address).'">DNS Records</a></li>
							<li><img src="/media/images/sidebar/firewall.png" /> <a href="/firewall/rules/view/'.rawurlencode($address).'">Firewall Rules</a></li>
							<li class="last"><img src="/media/images/sidebar/firewall.png" /> <a href="/firewall/rules/action/'.rawurlencode($address).'">Default Action</a></li>
						</ul>
					</li>';
		}
	}
	
	private function _load_interface_view_data($systemName,$interface,$last=NULL) {
		$addressData = "";
		
		if(isset($this->addresses[$this->interfaces[$systemName][$interface]])) {
			$addresses = $this->addresses[$this->interfaces[$systemName][$interface]];
			while($addresses) {
				$address = array_shift($addresses);
				if($addresses) {
					$addressData .= $this->_load_address_view_data($address);
				}
				else {
					$addressData .= $this->_load_address_view_data($address,"last");
				}	
			}
		}
		
		if($addressData != "") {
			return '<li class="expandable '.$last.'"><div class="hitarea expandable-hitarea"></div><img src="/media/images/sidebar/nic.png" /> <a href="/interface/view/'.$this->interfaces[$systemName][$interface].'">'.$interface.'</a>
						<ul style="display: none;">'.
							$addressData.
						'</ul>
					</li>';
			}
		else {
			return '<li class="expandable '.$last.'"><img src="/media/images/sidebar/nic.png" /> <a href="/interface/view/'.$this->interfaces[$systemName][$interface].'">'.$interface.'</a></li>';
		}
	}
	
	private function _load_system_view_data($systemName,$view,$last=NULL) {
		$systemData = "";
		
		$viewUrl = ($view=="OWNED")?self::$rwSystemImageUrl:self::$roSystemImageUrl;
		
		if(isset($this->interfaces[$systemName])) {
			$interfaces = array_keys($this->interfaces[$systemName]);
			while($interfaces) {
				$interface = array_shift($interfaces);
				if($interfaces) {
					$systemData .= $this->_load_interface_view_data($systemName,$interface);
				}
				else {
					$systemData .= $this->_load_interface_view_data($systemName,$interface,"last");
				}
			}
		}
		
		if($systemData != "") {
			return '<li class="expandable '.$last.'"><div class="hitarea expandable-hitarea"></div><img src="'.$viewUrl.'" /> <a href="/system/view/'.rawurlencode($systemName).'">'.$systemName.'</a>
			<ul style="display: none;">'.$systemData.
				'</ul>
			</li>';
		}
		else {
			return '<li class="'.$last.'"><img src="'.$viewUrl.'" /> <a href="/system/view/'.rawurlencode($systemName).'">'.$systemName.'</a></li>';
		}
	}
	
    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
	
	public function load_other_system_view_data() {
		$viewData = "";
		
		if($this->allSystems) {
			$systems = $this->allSystems;
			while($systems) {
				$systemName = array_shift($systems);
				if($systems) {
					$viewData .= $this->_load_system_view_data($systemName,"OTHER");
				}
				else {
					$viewData .= $this->_load_system_view_data($systemName,"OTHER","last");
				}
			}
		}
		
		return $viewData;
	}
	
	public function load_owned_system_view_data() {
		$viewData = "";
	
		if($this->ownedSystems) {
			foreach($this->ownedSystems as $systemName) {
				$viewData .= $this->_load_system_view_data($systemName,"OWNED");
			}
		}
		
		return $viewData;
	}
	
	public function load_owned_metahost_view_data() {
		$viewData = "";
	
		if($this->ownedMetahosts) {
			foreach($this->ownedMetahosts as $metahostName) {
				$viewData .= '<li class="expandable"><div class="hitarea expandable-hitarea"></div><img src="/media/images/sidebar/metahost.png" /> <a href="/firewall/metahosts/view/'.rawurlencode($metahostName).'">'.$metahostName.'</a>
				<ul style="display: none;">
					<li><img src="/media/images/sidebar/members.png" /> <a href="/firewall/metahost_members/view/'.rawurlencode($metahostName).'">Members</a></li>
					<li class="last"><img src="/media/images/sidebar/firewall.png" /> <a href="/firewall/metahost_rules/view/'.rawurlencode($metahostName).'">Rules</a></li>
				</ul>
			</li>';
			}
		}
		
		return $viewData;
	}
	
	public function load_other_metahost_view_data() {
		$viewData = "";
		
		if($this->otherMetahosts) {
			$metahosts = $this->otherMetahosts;
			
			while($metahosts) {
				$metahostName = array_shift($metahosts);
				if($metahosts) {
					$viewData .= '<li class="expandable"><div class="hitarea expandable-hitarea"></div><img src="/media/images/sidebar/metahost.png" /> <a href="/firewall/metahosts/view/'.rawurlencode($metahostName).'">'.$metahostName.'</a>
					<ul style="display: none;">
						<li><img src="/media/images/sidebar/members.png" /> <a href="/firewall/metahost_members/view/'.rawurlencode($metahostName).'">Members</a></li>
						<li class="last"><img src="/media/images/sidebar/firewall.png" /> <a href="/firewall/metahost_rules/view/'.rawurlencode($metahostName).'">Rules</a></li>
					</ul>
				</li>';
				}
				else {
					$viewData .= '<li class="expandable last"><div class="hitarea expandable-hitarea"></div><img src="/media/images/sidebar/metahost.png" /> <a href="/firewall/metahosts/view/'.rawurlencode($metahostName).'">'.$metahostName.'</a>
					<ul style="display: none;">
						<li><img src="/media/images/sidebar/members.png" /> <a href="/firewall/metahost_members/view/'.rawurlencode($metahostName).'">Members</a></li>
						<li class="last"><img src="/media/images/sidebar/firewall.png" /> <a href="/firewall/metahost_rules/view/'.rawurlencode($metahostName).'">Rules</a></li>
					</ul>
				</li>';
				}
			}
		}
		
		return $viewData;
	}
	
	public function load_owned_key_view_data() {
		$viewData = "";
		
		if($this->ownedKeys) {
			foreach($this->ownedKeys as $keyname) {
				$viewData .= '<li><img src="/media/images/sidebar/key.png" /> <a href="/resources/keys/view/'.rawurlencode($keyname).'">'.$keyname.'</a></li>';
			}
		}
		
		return $viewData;
	}
	
	public function load_other_key_view_data() {
		$viewData = "";
		
		if($this->otherKeys) {
			foreach($this->otherKeys as $keyname) {
				$viewData .= '<li><img src="/media/images/sidebar/key.png" /> <a href="/resources/keys/view/'.rawurlencode($keyname).'">'.$keyname.'</a></li>';
			}
		}
		
		return $viewData;
	}
	
	public function load_owned_zone_view_data() {
		$viewData = "";
		
		if($this->ownedZones) {
			foreach($this->ownedZones as $zone) {
				$viewData .= '<li><img src="/media/images/sidebar/zone.png" /> <a href="/resources/zones/view/'.rawurlencode($zone).'">'.$zone.'</a></li>';
			}
		}
		
		return $viewData;
	}
	
	public function load_other_zone_view_data() {
		$viewData = "";
		
		if($this->otherZones) {
			foreach($this->otherZones as $zone) {
				$viewData .= '<li><img src="/media/images/sidebar/zone.png" /> <a href="/resources/zones/view/'.rawurlencode($zone).'">'.$zone.'</a></li>';
			}
		}
		
		return $viewData;
	}
	
	public function load_owned_subnet_view_data() {
		$viewData = "";
		
		if($this->ownedSubnets) {
			foreach($this->ownedSubnets as $subnet) {
				$viewData .= '<li class="expandable"><div class="hitarea expandable-hitarea"></div><img src="/media/images/sidebar/ipaddr.png" /> <a href="/resources/subnets/view/'.rawurlencode($subnet).'">'.$subnet.'</a>
					<ul style="display: none">
					    <li><img src="/media/images/sidebar/statistic.png" /> <a href="/statistics/subnet_utilization/'.rawurlencode($subnet).'">Utilization</a></li>
						<li class="last"><img src="/media/images/sidebar/option.png" /> <a href="/dhcp/options/view/subnet/'.rawurlencode($subnet).'">DHCP Options</a></li>
					</ul>
				</li>';
			}
		}
		
		return $viewData;
	}
	
	public function load_other_subnet_view_data() {
		$viewData = "";
		
		if($this->otherSubnets) {
			foreach($this->otherSubnets as $subnet) {
				$viewData .= '<li class="expandable"><div class="hitarea expandable-hitarea"></div><img src="/media/images/sidebar/ipaddr.png" /> <a href="/resources/subnets/view/'.rawurlencode($subnet).'">'.$subnet.'</a>
					<ul style="display: none">
					    <li><img src="/media/images/sidebar/statistic.png" /> <a href="/statistics/subnet_utilization/'.rawurlencode($subnet).'">Utilization</a></li>
						<li class="last"><img src="/media/images/sidebar/option.png" /> <a href="/dhcp/options/view/subnet/'.rawurlencode($subnet).'">DHCP Options</a></li>
					</ul>
				</li>';
			}
		}
		
		return $viewData;
	}
	
	public function load_range_view_data() {
		$viewData = "";
		
		#$viewUrl = ($this->CI->api->isadmin())?self::$rwSystemImageUrl:self::$roSystemImageUrl;
		
		if($this->ranges) {
			foreach($this->ranges as $range) {
				$viewData .= '<li class="expandable"><div class="hitarea expandable-hitarea"></div><img src="/media/images/sidebar/range.png" /> <a href="/resources/ranges/view/'.rawurlencode($range).'">'.$range.'</a>
					<ul style="display: none">
						<li class="last"><img src="/media/images/sidebar/option.png" /> <a href="/dhcp/options/view/range/'.rawurlencode($range).'">DHCP Options</a></li>
						<li class="last"><img src="/media/images/sidebar/statistic.png" /> <a href="/statistics/range_utilization/'.rawurlencode($range).'">Utilization</a></li>
					</ul>
				</li>';
			}
		}
		
		return $viewData;
	}
	
	public function load_class_view_data() {
		$viewData = "";
		
		if($this->classes) {
			$classes = $this->classes;
			while($classes) {
				$class = array_shift($classes);
				if($classes) {
					$viewData .= '<li class="expandable"><div class="hitarea expandable-hitarea"></div><img src="/media/images/sidebar/class.png" /> <a href="/dhcp/classes/view/'.rawurlencode($class).'">'.$class.'</a>
						<ul style="display: none">
							<li class="last"><img src="/media/images/sidebar/option.png" /> <a href="/dhcp/options/view/class/'.$class.'">DHCP Options</a></li>
						</ul>
					</li>';
				}
				else {
					$viewData .= '<li class="expandable last"><div class="hitarea expandable-hitarea"></div><img src="/media/images/sidebar/class.png" /> <a href="/dhcp/classes/view/'.rawurlencode($class).'">'.$class.'</a>
						<ul style="display: none">
							<li class="last"><img src="/media/images/sidebar/option.png" /> <a href="/dhcp/options/view/class/'.$class.'">DHCP Options</a></li>
						</ul>
					</li>';
				}
			}
		}
		
		return $viewData;
	}

	public function load_network_system_data() {
		$viewData = "";

		if($this->netSystems) {
			$systems = $this->netSystems;
			while($systems) {
				$system = array_shift($systems);
				if($systems) {
					$viewData .= '<li class="expandable"><div class="hitarea expandable-hitarea"></div><img src="/media/images/sidebar/network.png" /> <a href="/system/view/'.rawurlencode($system).'">'.$system.'</a>
						<ul style="display: none">
							<li><a href="/switchports/view/'.rawurlencode($system).'">Switchports</a></li>
							<li class="last"><a href="/switchview/settings/'.rawurlencode($system).'">Switchview</a></li>
						</ul>
					</li>';
				}
				else {
					$viewData .= '<li class="expandable last"><div class="hitarea expandable-hitarea"></div><img src="/media/images/sidebar/network.png" /> <a href="/system/view/'.rawurlencode($system).'">'.$system.'</a>
						<ul style="display: none">
							<li><a href="/switchports/view/'.rawurlencode($system).'">Switchports</a></li>
							<li class="last"><a href="/switchview/settings/'.rawurlencode($system).'">Switchview</a></li>
						</ul>
					</li>';

				}
			}
		}

		return $viewData;
	}
	
	public function load_statistics_view_data() {
		return '<ul>
			<li><a href="/statistics/os_distribution">OS Distribution</a></li>
			<li class="last"><a href="/statistics/os_family_distribution">OS Family Distribution</a></li>
		</ul>';
	}
	
	public function reload() {
		$_SESSION['sidebar'] = serialize(new Sidebar());
	}
	
}
/* End of file sidebar.php */
/* Location: ./application/libraries/core/sidebar.php */
