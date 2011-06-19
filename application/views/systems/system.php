
<div class="system_resource_container">
	<div class="system_resource_title">
		<span class="resource_title_span"><?echo $system_name; if ($comment) { echo " ($comment)"; }?></span>
		<img class="resource_title_img"src="http://www.google.com/images/nav_logo72.png"></img>
	</div>

	<div class="system_resource_information">
		<table>
			<tr><td><em>Owner:</em></td><td><?echo $owner;?></td></tr>
			<tr><td><em>Type:</em></td><td><?echo $type;?></td></tr>
			<tr><td><em>OS:</em></td><td><?echo $os_name;?></td></tr>
		</table>
	</div>
	
	<div class="system_date_bar">Created on <?echo $date_created;?> - Modified by <?echo $last_modifier;?> on <?echo $date_modified;?></div>
</div>
