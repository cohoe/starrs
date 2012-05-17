<div class="item_container">
	<div class="resource_title_bar_style3">
		<div class="resource_title_bar_left"><?echo htmlentities($interface->get_interface_name()) . " (" . htmlentities($interface->get_mac()) . ")";?></div>
		<div class="interface_image"></div>
		<div class="resource_title_bar_right"><?echo htmlentities($interface->get_comment());?></div>
	</div>
	<div class="item_lower_bar_style3">Created on <?echo htmlentities($interface->get_date_created());?> - Modified by <?echo ($interface->get_last_modifier());?> on <?echo htmlentities($interface->get_date_modified());?></div>
</div>
