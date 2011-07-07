<?php

class CSS {
	private $CI;
	function load_css()
	{
		$CI =& get_instance();
		if($CI->config->item('skin'))
		{
			$skin = $CI->config->item('skin');
		}
		else
		{
			$skin = "impulse";
		}
		#echo link_tag("css/$skin/full/main.css");
		
	}
}
