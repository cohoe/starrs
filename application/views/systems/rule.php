<div class="rule_resource_container">
	<div class="rule_resource_title">
		<span class="item_title_span"><?echo "$comment";?></span>
	</div>
	<div class="rule_resource_information">
		<table class="resource_information_table">
		<!--
			<tr><td><em>Port:</em></td><td><?echo $port;?></td></tr>
			<tr><td><em>Transport:</em></td><td><?echo $transport;?></td></tr>
			<tr><td><em>Deny:</em></td><td><?echo $deny;?></td></tr>
		-->
		<tr><td><em>Port: </em><?echo $port;?></td><td><em>Transport: </em><?echo $transport;?></td><td><em>Deny: </em><?echo $deny;?></td></tr>
		</table>
	</div>
	
	<div class="rule_date_bar">Created on <?echo $date_created;?> - Modified by <?echo $last_modifier;?> on <?echo $date_modified;?></div>
</div>
