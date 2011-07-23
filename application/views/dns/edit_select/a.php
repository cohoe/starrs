<div class="item_information_area_container">
	Address Record (A, AAAA)
	<table class="dns_information_area_table">
		<tr>
			<th>DNS Name</th>
			<th>Type</th>
			<th>Edit</th>
		</tr>
		<tr>
			<td><?echo $record->get_hostname().".".$record->get_zone();?></td>
			<td><?echo $record->get_type();?></td>
			<td><a href="<?echo "/dns/edit/".$record->get_address()."/".$record->get_type()."/".$record->get_zone()."/".$record->get_hostname();?>">E</a></td>
		</tr>
	</table>
</div>