<div class="item_container">
	<ul>
	<? foreach($ranges as $range) {
		echo '<li><a href="/dhcp/options/view/range/'.rawurlencode($range->get_name()).'">'.htmlentities($range->get_name()).'</a></li>';
	}?>
	</ul>
</div>