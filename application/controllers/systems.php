<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Systems extends CI_Controller {

	public function index()
	{
		echo "You are working with a system<br>";
	}
	
	public function view($system_name=NULL)
	{
		if (!$system_name)
		{
			echo "Need to specify system<br>";
			die;
		}

		#$skin = "grid";
		$skin = "sunday";
		
		$system_info = $this->api->get_system_info($system_name);
		echo link_tag("css/$skin/full/address.css");
		echo link_tag("css/$skin/full/firewall.css");
		echo link_tag("css/$skin/full/interface.css");
		echo link_tag("css/$skin/full/main.css");
		echo link_tag("css/$skin/full/resource.css");
		echo link_tag("css/$skin/full/system.css");
		echo link_tag("css/$skin/full/item.css");

		$this->load->view("systems/system",$system_info);
		$interface_info = $this->api->get_system_interfaces($system_name);
		
		foreach ($interface_info as $interface)
		{
			$this->load->view("systems/interface",$interface);

			$address_info = $this->api->get_interface_addresses($interface['mac']);
			foreach ($address_info as $address)
			{
				$this->load->view("systems/address",$address);
				
				$fw_rules_info = $this->api->get_address_rules($address['address']);
				foreach ($fw_rules_info as $rule)
				{
					$this->load->view("systems/rule",$rule);
				}
			}
		}
	}
	
	public function edit($system_name=NULL)
	{
		if (!$system_name)
		{
			echo "Need to specify system<br>";
			die;
		}
		
		
		echo "Editing system \"$system_name\"";
	}
}
/* End of file system.php */
/* Location: ./application/controllers/system.php */
