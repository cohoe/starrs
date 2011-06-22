<div class="item_container">
	<div class="resource_title_bar_style3">
		<span class="resource_title_bar_left"><?echo $mac; if ($comment) { echo " ($comment)"; }?></span>
		<div class="interface_image"></div>
	</div>

	<div class="item_information_area_style3">
		<table class="item_information_area_table">
			<tr><td><em>MAC:</em></td><td><?echo $mac;?></td></tr>
			<tr><td><em>Date Created:</em></td><td><?echo $date_created;?></td></tr>
			<tr><td><em>Date Modified:</em></td><td><?echo $date_modified;?></td></tr>
			<tr><td><em>Last Modifier:</em></td><td><?echo $last_modifier;?></td></tr>
		</table>
	</div>
	
	<div class="item_lower_bar_style3">Created on <?echo $date_created;?> - Modified by <?echo $last_modifier;?> on <?echo $date_modified;?></div>
</div>
