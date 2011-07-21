<div class="item_information_area_container">
	Nameserver Records (NS)
	<table class="dns_information_area_table">
		<tr>
			<th>Zone</th>
			<th>Primary</th>
			<th>TTL</th>
			<th>Last Modifier</th>
		</tr>
		<? foreach ($records as $record) {
			echo "<tr>";
			echo "<td>".$record->get_zone()."</td>";
			echo "<td>".$record->get_isprimary()."</td>";
			echo "<td>".$record->get_ttl()."</td>";
			echo "<td>".$record->get_last_modifier()."</td>";
			echo "</tr>";
		}?>
	</table>
</div>