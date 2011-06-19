<div class="address_resource_container">
	<div class="address_resource_title">
		<span class="item_title_span"><?echo "$name ($comment)";?></span>
		<? if ($isprimary == 't') {?>
		<span class="interface_primary_span">Primary</span>
		<?}?>
	</div>
	<div class="address_resource_information">
		<table class="resource_information_table">
			<tr><td><em>Address:</em></td><td><?echo $address;?></td></tr>
			<tr><td><em>Configuration:</em></td><td><?echo $config;?></td></tr>
			<tr><td><em>Class:</em></td><td><?echo $class;?></td></tr>
		</table>
	</div>
	
	<div class="address_date_bar">Created on <?echo $date_created;?> - Modified by <?echo $last_modifier;?> on <?echo $date_modified;?></div>
</div>