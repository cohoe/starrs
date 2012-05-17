<div class="item_information_area_container">
	Address Record (A, AAAA)
	<table class="dns_information_area_table">
		<tr>
			<th>DNS Name</th>
			<th>Type</th>
			<th>TTL</th>
			<th>Last Modifier</th>
		</tr>
		<tr>
			<td><?echo htmlentities($record->get_hostname()).".".htmlentities($record->get_zone());?></td>
			<td><?echo htmlentities($record->get_type());?></td>
			<td><?echo htmlentities($record->get_ttl());?></td>
			<td><?echo htmlentities($record->get_last_modifier());?></td>
		</tr>
	</table>
</div>