<div class="item_container">
	<ul>
	<? foreach($classes as $class) {
		echo '<li><a href="/dhcp/options/view/class/'.rawurlencode($class->get_class()).'">'.htmlentities($class->get_class()).'</a></li>';
	}?>
	</ul>
</div>