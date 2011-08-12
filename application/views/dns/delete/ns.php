<div class="item_information_area_container">
	Nameserver Records (NS)
	<table class="dns_information_area_table">
		<tr>
			<th>Zone</th>
			<th>Primary</th>
			<th>Delete</th>
		</tr>
		<? foreach ($records as $record) {
			echo "<tr>";
			echo "<td>".htmlentities($record->get_zone())."</td>";
			echo "<td>".($record->get_isprimary())?"Yes":"No"."</td>";
			echo "<td><a href=\"/dns/delete/".rawurlencode($record->get_address())."/".rawurlencode($record->get_type())."/".rawurlencode($record->get_zone())."/".rawurlencode($record->get_hostname())."\">X</a></td>";
			echo "</tr>";
		}?>
	</table>
</div>