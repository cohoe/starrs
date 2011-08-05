<div class="item_container">
	<ul>
	<? foreach($subnets as $subnet) {
		echo '<li><a href="/dhcp/options/view/subnet/'.$subnet->get_subnet().'">'.$subnet->get_subnet().'</a></li>';
	}?>
	</ul>
</div>