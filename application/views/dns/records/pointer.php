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
			echo "<td>".htmlentities($record->get_alias())."</td>";
			echo "<td>".htmlentities($record->get_hostname()).".".htmlentities($record->get_zone())."</td>";
			echo "<td>".htmlentities($record->get_extra())."</td>";
			echo "<td>".htmlentities($record->get_type())."</td>";
			echo "<td>".htmlentities($record->get_ttl())."</td>";
			echo "<td>".htmlentities($record->get_last_modifier())."</td>";
			echo "</tr>";
		}?>
	</table>
</div>