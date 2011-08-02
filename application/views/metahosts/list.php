<div class="item_container">
	<?foreach($mhosts as $mhost) {?>
		<a href="/firewall/metahosts/view/<?echo $mhost->get_name();?>"><div class="system_list_box"><?echo $mhost->get_name();?></div></a>
	<?}?>
</div>
