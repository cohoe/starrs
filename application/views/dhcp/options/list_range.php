<div range="item_container">
	<ul>
	<? foreach($ranges as $range) {
		echo '<li><a href="/dhcp/options/view/range/'.$range->get_name().'">'.$range->get_name().'</a></li>';
	}?>
	</ul>
</div>