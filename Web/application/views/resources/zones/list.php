<div class="item_container">
	<ul>
		<?foreach ($dnsZones as $zone) {
			echo "<li><a href=\"/resources/zones/view/".rawurlencode($zone->get_zone())."\">".htmlentities($zone->get_zone())."</a></li>";
		}?>
	</ul>
</div>
