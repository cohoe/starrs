<?php
class Reference extends CI_Controller {

	public function index()
	{
		$skin = "grid";
		echo link_tag("css/$skin/full/main.css");	
        #echo link_tag("css/$skin/full/reference.css");

		$schemas = array('dhcp','dns','documentation','firewall','ip','management','systems');

		foreach ($schemas as $schema)
		{
			$data['name'] = $schema;
			$this->load->view('reference/index', $data);
		}
	}

	public function view($schema = "none")
	{
		$skin = "impulse";
		echo link_tag("css/$skin/full/main.css");
		$functions = $this->api->get_schema_documentation($schema);

		foreach ($functions as $function)
		{
			$arguments = $this->api->get_function_parameters($function['specific_name']);
			$function['args'] = $arguments;
			$this->load->view('reference/function.php', $function);
		}
	}
}
