<div class="item_container">
	<ul>
		<?foreach ($ipRanges as $ipRange) {
			echo "<li><a href=\"/resources/ranges/view/".rawurlencode($ipRange->get_name())."\">".$ipRange->get_name()."</a></li>";
		}?>
	</ul>
</div>
