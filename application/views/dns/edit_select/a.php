<div class="item_information_area_container">
	Address Record (A, AAAA)
	<table class="dns_information_area_table">
		<tr>
			<th>DNS Name</th>
			<th>Type</th>
			<th>Edit</th>
		</tr>
		<? foreach ($records as $record) {
			echo "<tr>";
			echo "<td>".$record->get_hostname().".".$record->get_zone()."</td>";
			echo "<td>".$record->get_type()."</td>";
			echo "<td><a href=\"/dns/edit/".$record->get_address()."/".$record->get_type()."/".$record->get_zone()."/".$record->get_hostname()."\">E</a></td>";
			echo "</tr>";
		}?>
	</table>
</div>