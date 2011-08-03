<div class="item_container">
	<ul>
		<?foreach ($dnsKeys as $key) {
			echo "<li><a href=\"/resources/keys/view/".urlencode($key->get_keyname())."\">".$key->get_keyname()." (".$key->get_owner().")</a></li>";
		}?>
	</ul>
</div>