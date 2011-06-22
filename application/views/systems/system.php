<div class="item_container">
	<div class="resource_title_bar_style4">
		<span class="resource_title_bar_left"><?echo $system_name; if ($comment) { echo " ($comment)"; }?></span>
		<img class="system_image"src="http://www.google.com/images/nav_logo72.png"></img>
	</div>

	<div class="item_information_area_style4">
		<table class="item_information_area_table">
			<tr><td><em>Owner:</em></td><td><?echo $owner;?></td></tr>
			<tr><td><em>Type:</em></td><td><?echo $type;?></td></tr>
			<tr><td><em>OS:</em></td><td><?echo $os_name;?></td></tr>
		</table>
	</div>
	
	<div class="item_lower_bar_style4">Created on <?echo $date_created;?> - Modified by <?echo $last_modifier;?> on <?echo $date_modified;?></div>
</div>
