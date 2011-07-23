<div class="item_information_area_container">
	Pointer Records (CNAME, SRV)
	<table class="dns_information_area_table">
		<tr>
			<th>Alias</th>
			<th>Target</th>
			<th>Extra</th>
			<th>Type</th>
			<th>Delete</th>
		</tr>
		<? foreach ($records as $record) {
			echo "<tr>";
			echo "<td>".$record->get_alias()."</td>";
			echo "<td>".$record->get_hostname().".".$record->get_zone()."</td>";
			echo "<td>".$record->get_extra()."</td>";
			echo "<td>".$record->get_type()."</td>";
			echo "<td><a href=\"/dns/delete/".$record->get_address()."/".$record->get_type()."/".$record->get_zone()."/".$record->get_hostname()."/".$record->get_alias()."\">X</a></td>";
			echo "</tr>";
		}?>
	</table>
</div>