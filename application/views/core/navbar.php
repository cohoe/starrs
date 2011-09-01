<div class="navbar" id='navBar'>
	<div>
		<div class="nav_title"><?echo htmlentities($navbar->get_title());?></div>
		<div class="nav_user"><?echo htmlentities($navbar->get_user())." (".strtolower(htmlentities($navbar->get_priv())).")";?></div>
	</div>
	<br>
	<? foreach ($navbar->get_navOptions() as $menuOption) {

		if(strcasecmp($menuOption['title'],$navbar->get_active_page()) == 0) {?>
			<a href="<?echo htmlentities($menuOption['link']);?>"><div class="nav_item_left nav_item_left_active"><span><?echo htmlentities($menuOption['title']);?></span></div></a>
		<?} else {?>
			<a href="<?echo htmlentities($menuOption['link']);?>"><div class="nav_item_left"><span><?echo htmlentities($menuOption['title']);?></span></div></a>
		<?}
	}
	
	//echo "<a href=\"".$navbar->get_help_link()."\"><div class=\"nav_item_right\"><span>Help</span></div></a>";
	// The link will be followed if a helpDiv does not exist, otherwise it'll be toggled
	echo "<a href='{$navbar->get_help_link()}' onClick='return toggleHelp();'><div class='nav_item_right'><span>Help</span></div></a>";
	//echo "<a onClick='toggleHelp()'><div class='nav_item_right'><span>Help</span></div></a>";
	
	if($navbar->get_cancel() == true) {
		echo "<a href=\"".$navbar->get_cancel_link()."\"><div class=\"nav_item_right\"><span>Cancel</span></div></a>";
	}
	if($navbar->get_delete() == true) {
		echo "<a href=\"".$navbar->get_delete_link()."\"><div class=\"nav_item_right\"><span>Delete</span></div></a>";
	}
	if($navbar->get_edit() == true) {
		echo "<a href=\"".$navbar->get_edit_link()."\"><div class=\"nav_item_right\"><span>Edit</span></div></a>";
	}
	if($navbar->get_create() == true) {
		echo "<a href=\"".$navbar->get_create_link()."\"><div class=\"nav_item_right\"><span>Create</span></div></a>";
	} ?>
</div>
