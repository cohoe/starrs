<div class="item_container">
	<ul>
	<? foreach($subnets as $subnet) {
		echo '<li><a href="/dhcp/options/view/subnet/'.rawurlencode($subnet->get_subnet()).'">'.htmlentities($subnet->get_subnet()).'</a></li>';
	}?>
	</ul>
</div>