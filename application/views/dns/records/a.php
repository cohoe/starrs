<div class="item_information_area_container">
	Address Record (A, AAAA)
	<table class="dns_information_area_table">
		<tr>
			<th>DNS Name</th>
			<th>Type</th>
			<th>TTL</th>
			<th>Last Modifier</th>
		</tr>
		<tr>
			<td><?echo $record->get_hostname().".".$record->get_zone();?></td>
			<td><?echo $record->get_type();?></td>
			<td><?echo $record->get_ttl();?></td>
			<td><?echo $record->get_last_modifier();?></td>
		</tr>
	</table>
</div>