<? 
#print_r($navbar->get_options()); 

#echo array_keys($navbar->get_options());

?>

<div class="navbar">
	<span class="nav_title"><?echo $navbar->get_title();?></span>
	<span class="nav_user"><?echo $navbar->get_user()." (".strtolower($navbar->get_priv()).")";?></span>
	<br />

	<?
	foreach ($navbar->get_options() as $menuOption) {

		if(strcasecmp($menuOption['title'],$navbar->get_active_page()) == 0) {?>
			<a href="<?echo $navbar->get_context()."/".$menuOption['link'];?>"><div class="nav_item_left nav_item_left_active"><span><?echo $menuOption['title'];?></span></div></a>
		<?}
		else {?>
			<a href="<?echo $navbar->get_context()."/".$menuOption['link'];?>"><div class="nav_item_left"><span><?echo $menuOption['title'];?></span></div></a>
		<?}
	}
	if($navbar->get_deletable() == true) {
		echo "<a href=\"/systems/delete/".$navbar->get_title()."\"><div class=\"nav_item_right\"><span>Delete</span></div></a>";
	}
	if($navbar->get_editable() == true) {
		echo "<a href=\"/systems/edit/".$navbar->get_title()."\"><div class=\"nav_item_right\"><span>Edit</span></div></a>";
	}
	?>
</div>
