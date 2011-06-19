<div class="interface_resource_container">
	<div class="interface_resource_title">
		<span class="resource_title_span"><?echo $mac; if ($comment) { echo " ($comment)"; }?></span>
		<div class="interface_title_img"></div>
	</div>

	<div class="interface_resource_information">
		<table class="resource_information_table">
			<tr><td><em>MAC:</em></td><td><?echo $mac;?></td></tr>
			<tr><td><em>Date Created:</em></td><td><?echo $date_created;?></td></tr>
			<tr><td><em>Date Modified:</em></td><td><?echo $date_modified;?></td></tr>
			<tr><td><em>Last Modifier:</em></td><td><?echo $last_modifier;?></td></tr>
		</table>
	</div>
	
	<div class="interface_date_bar">Created on <?echo $date_created;?> - Modified by <?echo $last_modifier;?> on <?echo $date_modified;?></div>
</div>
