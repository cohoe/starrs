<div class="navbar">
	<span class="nav_title"><?echo $title;?></span>
	<?foreach ($options as $menuOption) {
		echo "<div class=\"nav_item\"><span>".$menuOption."</span></div>";
	}
	if($edit == true) {
		echo "<a href=\"http://localhost/mockup/edit/<?#echo $systemName;?>\"><div class=\"edit\"><span>Edit</span></div></a>";
	}
	?>
</div>