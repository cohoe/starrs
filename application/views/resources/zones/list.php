<div class="item_container">
	<ul>
		<?foreach ($dnsZones as $zone) {
			echo "<li><a href=\"/resources/zones/view/".urlencode($zone->get_zone())."\">".$zone->get_zone()."</a></li>";
		}?>
	</ul>
</div>
