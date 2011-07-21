<div class="item_information_area_container">
	Pointer Records (CNAME, SRV)
	<table class="dns_information_area_table">
		<tr>
			<th>Alias</th>
			<th>Target</th>
			<th>Extra</th>
			<th>Type</th>
			<th>TTL</th>
			<th>Last Modifier</th>
		</tr>
		<? foreach ($records as $record) {
			echo "<tr>";
			echo "<td>".$record->get_alias()."</td>";
			echo "<td>".$record->get_hostname().".".$record->get_zone()."</td>";
			echo "<td>".$record->get_extra()."</td>";
			echo "<td>".$record->get_type()."</td>";
			echo "<td>".$record->get_ttl()."</td>";
			echo "<td>".$record->get_last_modifier()."</td>";
			echo "</tr>";
		}?>
	</table>
</div>