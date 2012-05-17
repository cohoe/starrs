<div class="item_container">
	<?foreach($mhosts as $mhost) {?>
		<a href="/metahosts/view/<?echo rawurlencode($mhost->get_name());?>"><div class="system_list_box"><?echo htmlentities($mhost->get_name());?></div></a>
	<?}?>
</div>
