<div class="item_information_area_container">
	Text Records (TXT, SPF)
	<table class="dns_information_area_table">
		<tr>
			<th>Text</th>
			<th>TTL</th>
			<th>Last Modifier</th>
		</tr>
		<? foreach ($records as $record) {
			echo "<tr>";
			echo "<td>".htmlentities($record->get_text())."</td>";
			echo "<td>".htmlentities($record->get_ttl())."</td>";
			echo "<td>".htmlentities($record->get_last_modifier())."</td>";
			echo "</tr>";
		}?>
	</table>
</div>