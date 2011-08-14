<?php
if($addr->get_dynamic() == TRUE) {
	$address = "Dynamic";
}
else {
	$address = $addr->get_address();
}
?>
<div class="item_information_area">
	<div class="interface_box">
		<div class="interface_box_nav">
			<? foreach ($navbar->get_navOptions() as $menuOption) {
				if(strcasecmp($menuOption['title'],$navbar->get_active_page()) == 0) {?>
					<a href="<?= $menuOption['link'];?>"><div class="nav_item_left nav_item_left_active"><span><?= $menuOption['title'];?></span></div></a>
				<?} 
				else {?>
					<a href="<?= $menuOption['link'];?>"><div class="nav_item_left"><span><?= $menuOption['title'];?></span></div></a>
				<?}
			}
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
			}?>
		</div>
		<table class="item_information_area_table">
			<tr><td><em>Address:</em></td><td><?echo htmlentities($address);?></td></tr>
			<tr><td><em>DNS Name:</em></td><td><?echo htmlentities($addr->get_fqdn());?></td></tr>
			<tr><td><em>Family:</em></td><td><?echo htmlentities("IPv".$addr->get_family());?></td></tr>
			<tr><td><em>Range:</em></td><td><?echo htmlentities($addr->get_range());?></td></tr>
			<tr><td><em>Configuration:</em></td><td><?echo htmlentities($addr->get_config());?></td></tr>
			<tr><td><em>Class:</em></td><td><?echo htmlentities($addr->get_class());?></td></tr>
			<tr><td><em>Primary?:</em></td><td><?echo htmlentities(($addr->get_isprimary() == 't') ? "True" : "False");?></td></tr>
			<tr><td><em>Comment:</em></td><td><?echo htmlentities($addr->get_comment());?></td></tr>
		</table>
		<!--<img class="system_image" src=<?#echo base_url() . $this->impulselib->get_os_img_path($system->get_os_name())?>></img>-->
		<div class="infobar">
			<span class="infobar_text">Created on <?echo htmlentities($addr->get_date_created());?> - Modified by <?echo htmlentities($addr->get_last_modifier());?> on <?echo htmlentities($addr->get_date_modified());?></span>
		</div>
	</div>
</div>