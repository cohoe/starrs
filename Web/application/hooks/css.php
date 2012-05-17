<?php

class CSS {
	private $CI;
	function load_css()
	{
		#$CI =& get_instance();
		#if($CI->config->item('skin'))
		#{
		#	$skin = $CI->config->item('skin');
		#}
		#else
		#{
			#$skin = "impulse";
		#	$skin = "grid";
		#}
		#echo link_tag("css/$skin/full/main.css");
		#echo link_tag("css/mockup/main.css");
		#echo link_tag("css/mockup/impulse.css");
	}
}
