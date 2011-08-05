<div class="item_container">
	<ul>
	<? foreach($classes as $class) {
		echo '<li><a href="/dhcp/options/view/class/'.$class->get_class().'">'.$class->get_class().'</a></li>';
	}?>
	</ul>
</div>