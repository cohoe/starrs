<div class="item_information_area_container">
	Pointer Records (CNAME, SRV)
	<table class="dns_information_area_table">
		<tr>
			<th>Alias</th>
			<th>Target</th>
			<th>Extra</th>
			<th>Type</th>
			<th>Edit</th>
		</tr>
		<? foreach ($records as $record) {
			$url = "/dns/edit/";
			$url .= rawurlencode($record->get_address()) . "/";
			$url .= rawurlencode($record->get_type()) . "/";
			$url .= rawurlencode($record->get_zone()) . "/";
			$url .= rawurlencode($record->get_hostname()) . "/";
			$url .= rawurlencode($record->get_alias());
			
			echo "<tr>";
			echo "<td>".htmlentities($record->get_alias())."</td>";
			echo "<td>".htmlentities($record->get_hostname()).".".htmlentities($record->get_zone())."</td>";
			echo "<td>".htmlentities($record->get_extra())."</td>";
			echo "<td>".htmlentities($record->get_type())."</td>";
			echo "<td><a href='{$url}'>E</a></td>";
			echo "</tr>";
		}?>
	</table>
</div>