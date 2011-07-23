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
			echo "<td>".$record->get_zone()."</td>";
			echo "<td>".$record->get_isprimary()."</td>";
			echo "<td><a href=\"/dns/delete/".$record->get_address()."/".$record->get_type()."/".$record->get_zone()."/".$record->get_hostname()."\">X</a></td>";
			echo "</tr>";
		}?>
	</table>
</div>