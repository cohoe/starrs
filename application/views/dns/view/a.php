<div class="item_information_area_container">
	Address Record (A, AAAA)
	<table class="dns_information_area_table">
		<tr>
			<th>DNS Name</th>
			<th>Type</th>
			<th>TTL</th>
			<th>Last Modifier</th>
		</tr>
		<? foreach ($records as $record) {
			echo "<tr>";
			echo "<td>".$record->get_hostname().".".$record->get_zone()."</td>";
			echo "<td>".$record->get_type()."</td>";
			echo "<td>".$record->get_ttl()."</td>";
			echo "<td>".$record->get_last_modifier()."</td>";
			echo "</tr>";
		}?>
	</table>
</div>