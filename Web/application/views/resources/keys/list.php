<div class="item_container">
	<ul>
		<?foreach ($dnsKeys as $key) {
			echo "<li><a href=\"/resources/keys/view/".rawurlencode($key->get_keyname())."\">".htmlentities($key->get_keyname())." (".htmlentities($key->get_owner()).")</a></li>";
		}?>
	</ul>
</div>