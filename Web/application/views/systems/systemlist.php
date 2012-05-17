<div class="item_container">
	<?foreach($systems as $sys) {?>
		<a href="/system/view/<?echo rawurlencode($sys->get_system_name());?>"><div class="system_list_box"><?echo htmlentities($sys->get_system_name());?></div></a>
	<?}?>
</div>
