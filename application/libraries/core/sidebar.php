<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

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
	
	private static $rwSystemImageUrl = "http://sub.obive.net/up.png";
	private static $roSystemImageUrl = "http://sub.obive.net/error.png";
	private static $xxSystemImageUrl = "http://sub.obive.net/down.png";
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	public function __construct() {
		$this->CI =& get_instance();
		$currentUser = $this->CI->api->get->current_user();
		try {
			$this->ownedSystems = $this->CI->api->systems->list->owned_systems($currentUser);
			foreach($this->ownedSystems as $system) {
				$this->_load_system_data($system);
			}
		}
		catch(ObjectNotFoundException $onfE) {}
		try {	
			$this->allSystems = $this->CI->api->systems->list->other_systems($currentUser);
			foreach($this->allSystems as $system) {
				$this->_load_system_data($system);
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
		$this->interfaces[$system] = $this->CI->api->systems->list->interfaces($system);
		foreach($this->interfaces[$system] as $interface) {
			$this->addresses[$interface] = $this->CI->api->systems->list->interface_addresses($interface);
		}
	}
	
	private function _load_address_view_data($address) {
		return '<li class="expandable"><div class="hitarea expandable-hitarea"></div><a href="/addresses/view/'.$address.'">.'.$address.'</a>
					<ul style="display: none;">
						<li><a href="/dns/view/'.$address.'">DNS Records</a></li>
						<li class="last"><a href="/firewall/rules/view/'.$address.'">Firewall Rules</a></li>
					</ul>
				</li>';
	}
	
	private function _load_interface_view_data($systemName,$interface) {
		
		$addressData = "";
		
		foreach($this->addresses[$this->interfaces[$systemName][$interface]] as $address) {
			$addressData .= $this->_load_address_view_data($address);
		}
		return '<li class="expandable"><div class="hitarea expandable-hitarea"></div><img src="/media/images/sidebar/nic.png" /> <a href="/interfaces/view/'.$this->interfaces[$systemName][$interface].'">'.$interface.'</a>
					<ul style="display: none;">'.
						$addressData.
					'</ul>
				</li>';
	}
	
	private function _load_system_view_data($systemName,$view) {
		$systemData = "";
		
		$viewUrl = ($view=="OWNED")?self::$rwSystemImageUrl:self::$roSystemImageUrl;
		
		if(isset($this->interfaces[$systemName])) {
			foreach(array_keys($this->interfaces[$systemName]) as $interface) {
				$systemData = $this->_load_interface_view_data($systemName,$interface);
			}
		}
		return '<li class="expandable"><div class="hitarea expandable-hitarea"></div><img src="'.$viewUrl.'" /> <a href="/systems/view/'.$systemName.'">'.$systemName.'</a>
			<ul style="display: none;">'.$systemData.
			'</ul>
		</li>';
	}
	
    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
	
	public function load_other_system_view_data() {
		$viewData = "";
		
		foreach($this->allSystems as $systemName) {
			$viewData .= $this->_load_system_view_data($systemName,"OTHER");
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
				$viewData .= '<li class="expandable"><div class="hitarea expandable-hitarea"></div><img src="'.self::$rwSystemImageUrl.'" /> <a href="/firewall/metahosts/view/'.$metahostName.'">'.$metahostName.'</a>
				<ul style="display: none;">
					<li><a href="/firewall/metahost_members/view/'.$metahostName.'">Members</a></li>
					<li class="last"><a href="/firewall/metahosts/rules/view/'.$metahostName.'">Rules</a></li>
				</ul>
			</li>';
			}
		}
		
		return $viewData;
	}
	
	public function load_other_metahost_view_data() {
		$viewData = "";
		
		if($this->otherMetahosts) {
			foreach($this->otherMetahosts as $metahostName) {
				$viewData .= '<li class="expandable"><div class="hitarea expandable-hitarea"></div><img src="'.self::$roSystemImageUrl.'" /> <a href="/firewall/metahosts/view/'.$metahostName.'">'.$metahostName.'</a>'.
					'<ul style="display: none;">
						<li><a href="/firewall/metahost_members/view/'.$metahostName.'">Members</a></li>
						<li class="last"><a href="/firewall/metahosts/rules/view/'.$metahostName.'">Rules</a></li>
					</ul>
				</li>';
			}
		}
		
		return $viewData;
	}
	
	public function load_owned_key_view_data() {
		$viewData = "";
		
		if($this->ownedKeys) {
			foreach($this->ownedKeys as $keyname) {
				$viewData .= '<li><img src="'.self::$rwSystemImageUrl.'" /> <a href="/resources/keys/view/'.$keyname.'">'.$keyname.'</a></li>';
			}
		}
		
		return $viewData;
	}
	
	public function load_other_key_view_data() {
		$viewData = "";
		
		if($this->otherKeys) {
			foreach($this->otherKeys as $keyname) {
				$viewData .= '<li><img src="'.self::$xxSystemImageUrl.'" /> <a href="/resources/keys/view/'.$keyname.'">'.$keyname.'</a></li>';
			}
		}
		
		return $viewData;
	}
	
	public function load_owned_zone_view_data() {
		$viewData = "";
		
		if($this->ownedZones) {
			foreach($this->ownedZones as $zone) {
				$viewData .= '<li><img src="'.self::$rwSystemImageUrl.'" /> <a href="/resources/zones/view/'.$zone.'">'.$zone.'</a></li>';
			}
		}
		
		return $viewData;
	}
	
	public function load_other_zone_view_data() {
		$viewData = "";
		
		if($this->otherZones) {
			foreach($this->otherZones as $zone) {
				$viewData .= '<li><img src="'.self::$roSystemImageUrl.'" /> <a href="/resources/zones/view/'.$zone.'">'.$zone.'</a></li>';
			}
		}
		
		return $viewData;
	}
	
	public function load_owned_subnet_view_data() {
		$viewData = "";
		
		if($this->ownedSubnets) {
			foreach($this->ownedSubnets as $subnet) {
				$viewData .= '<li><img src="'.self::$rwSystemImageUrl.'" /> <a href="/resources/subnets/view/'.$subnet.'">'.$subnet.'</a></li>';
			}
		}
		
		return $viewData;
	}
	
	public function load_other_subnet_view_data() {
		$viewData = "";
		
		if($this->otherSubnets) {
			foreach($this->otherSubnets as $subnet) {
				$viewData .= '<li><img src="'.self::$roSystemImageUrl.'" /> <a href="/resources/subnets/view/'.$subnet.'">'.$subnet.'</a></li>';
			}
		}
		
		return $viewData;
	}
	
	public function load_range_view_data() {
		$viewData = "";
		
		$viewUrl = ($this->CI->api->isadmin())?self::$rwSystemImageUrl:self::$roSystemImageUrl;
		
		if($this->ranges) {
			foreach($this->ranges as $range) {
				$viewData .= '<li><img src="'.$viewUrl.'" /> <a href="/resources/ranges/view/'.$range.'">'.$range.'</a></li>';
			}
		}
		
		return $viewData;
	}
	
}
/* End of file sidebar.php */
/* Location: ./application/libraries/core/sidebar.php */
