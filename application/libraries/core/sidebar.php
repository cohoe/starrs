<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Sidebar {

	////////////////////////////////////////////////////////////////////////
	// MEMBER VARIABLES
	
	private $navHeadings;
	
	////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR
	
	public function __construct() {
		$systems['Owned'] = "/systems/owned";
		$systems['All'] = "/systems/all";
		$this->navHeadings['Systems'] = new Navitem('Systems','/systems',$systems);
		
		$metahosts['Owned'] = "/firewall/metahosts/owned";
		$metahosts['All'] = "/firewall/metahosts/all";
		$this->navHeadings['Metahosts'] = new Navitem('Metahosts','/firewall/metahosts',$metahosts);

		$resources['Keys'] = "/resources/keys";
		$resources['Zones'] = "/resources/zones";
		$resources['Subnets']['Base'] = "/resources/subnets";
		$resources['Subnets']['Owned'] = "/resources/subnets/owned";
		$resources['Subnets']['All'] = "/resources/subnets/all";
		$resources['Ranges'] = "/resources/ranges";
		$this->navHeadings['Resources'] = new Navitem('Resources','/resources',$resources);
		
		$dhcp['Classes'] = "/dhcp/classes/";
		$dhcp['Global Options'] = "/dhcp/options/view/global";
		$this->navHeadings['DHCP'] = new Navitem('DHCP','/dhcp',$dhcp);
		
		$admin['Site Configuration'] = "/admin/configuration/view/site";
		$this->navHeadings['Administration'] = new Navitem('Administration','/admin',$admin);
		
		$reference['API'] = "/reference/api";
		$reference['Help'] = "/reference/help";
		$this->navHeadings['Reference'] = new Navitem('Reference','/reference',$reference);
		
		$output['DHCP Config'] = "/output/view/dhcpd.conf";
		$output['Firewall Default Queue'] = "/output/view/fw_default_queue";
		$this->navHeadings['Output'] = new Navitem('Output','/output',$output);
		
		#$this->navHeadings['Statistics'] = "/statistics";
		#$this->navHeadings['Administration'] = "/admin";
		#$this->navHeadings['Output'] = "/output";
	}
	
	//////////////////////////////////////////////////////////////////////
	/// GETTERS
	
	public function get_nav_headings()  { return $this->navHeadings; }
	
	//////////////////////////////////////////////////////////////////////
	/// SETTERS
	
	////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS

    ////////////////////////////////////////////////////////////////////////
	// PUBLIC METHODS
	
}
/* End of file sidebar.php */
/* Location: ./application/libraries/core/sidebar.php */