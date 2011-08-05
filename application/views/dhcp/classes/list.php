<div class="item_container">
	<? foreach($classes as $class) {
		echo '<a href="/dhcp/classes/view/'.urlencode($class->get_class()).'"><div class="system_list_box">'.$class->get_class().'</div></a>';
	} ?>
</div>
