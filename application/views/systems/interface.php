<div class="item_container">
	<div class="resource_title_bar_style3">
		<div class="resource_title_bar_left"><?echo $interface->get_interface_name() . " (" . $interface->get_mac() . ")";?></div>
		<div class="interface_image"></div>
		<div class="resource_title_bar_right"><?if ($interface->get_comment()) { $comment = $interface->get_comment(); echo "$comment"; }?></div>
	</div>
	<div class="item_lower_bar_style3">Created on <?echo $interface->get_date_created();?> - Modified by <?echo $interface->get_last_modifier();?> on <?echo $interface->get_date_modified();?></div>
</div>
