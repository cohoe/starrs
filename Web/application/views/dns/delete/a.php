<div class="item_information_area_container">
	Address Record (A, AAAA)
	<table class="dns_information_area_table">
		<tr>
			<th>DNS Name</th>
			<th>Type</th>
			<th>Delete</th>
		</tr>
		<? foreach ($records as $record) {
			echo "<tr>";
			echo "<td>".htmlentities($record->get_hostname()).".".htmlentities($record->get_zone())."</td>";
			echo "<td>".htmlentities($record->get_type())."</td>";
			echo "<td><a href=\"/dns/delete/".rawurlencode($record->get_address())."/".rawurlencode($record->get_type())."/".rawurlencode($record->get_zone())."/".rawurlencode($record->get_hostname())."\">X</a></td>";
			echo "</tr>";
		}?>
	</table>
</div>