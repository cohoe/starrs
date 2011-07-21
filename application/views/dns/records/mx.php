<div class="item_information_area_container">
	Mailserver Records (MX)
	<table class="dns_information_area_table">
		<tr>
			<th>Preference</th>
			<th>TTL</th>
			<th>Last Modifier</th>
		</tr>
		<? foreach ($records as $record) {
			echo "<tr>";
			echo "<td>".$record->get_preference()."</td>";
			echo "<td>".$record->get_ttl()."</td>";
			echo "<td>".$record->get_last_modifier()."</td>";
			echo "</tr>";
		}?>
	</table>
</div>