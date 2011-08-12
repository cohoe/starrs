<div class="item_container">
	<? foreach($classes as $class) {
		echo '<a href="/dhcp/classes/view/'.rawurlencode($class->get_class()).'"><div class="system_list_box">'.htmlentities($class->get_class()).'</div></a>';
	} ?>
</div>
