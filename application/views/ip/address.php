<div class="item_container">
	<div class="item_title_style2">
		<span class="item_title_bar_left"><?echo "$name ($comment)";?></span>
		<? if ($isprimary == 't') {?>
		<span class="item_title_bar_right">Primary</span>
		<?}?>
	</div>
	<div class="item_information_area_style2">
		<table class="item_information_area_table">
			<tr><td><em>Address:</em></td><td><?echo $address;?></td></tr>
			<tr><td><em>Configuration:</em></td><td><?echo $config;?></td></tr>
			<tr><td><em>Class:</em></td><td><?echo $class;?></td></tr>
		</table>
	</div>
	
	<div class="item_lower_bar_style2">Created on <?echo $date_created;?> - Modified by <?echo $last_modifier;?> on <?echo $date_modified;?></div>
</div>