<div class="item_information_area_container">
	Address Record (A, AAAA)
	<table class="dns_information_area_table">
		<tr>
			<th>DNS Name</th>
			<th>Type</th>
			<th>Delete</th>
		</tr>
		<tr>
			<td><?echo $record->get_hostname().".".$record->get_zone();?></td>
			<td><?echo $record->get_type();?></td>
			<td><a href="<?echo "/dns/delete/".$record->get_address()."/".$record->get_type()."/".$record->get_zone()."/".$record->get_hostname();?>">X</a></td>
		</tr>
	</table>
</div>