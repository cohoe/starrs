<div class="item_information_area">
	<div class="interface_box">
		<div class="interface_box_nav">
			<? foreach ($navbar->get_navOptions() as $menuOption) {
				if(strcasecmp($menuOption['title'],$navbar->get_active_page()) == 0) {?>
					<a href="<?echo $menuOption['link'];?>"><div class="nav_item_left nav_item_left_active"><span><?echo $menuOption['title'];?></span></div></a>
				<?} 
				else {?>
					<a href="<?echo $menuOption['link'];?>"><div class="nav_item_left"><span><?echo $menuOption['title'];?></span></div></a>
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
			<tr><td><em>Name:</em></td><td><?echo htmlentities($interface->get_interface_name());?></td></tr>
			<tr><td><em>MAC:</em></td><td><?echo htmlentities($interface->get_mac());?></td></tr>
			<tr><td><em>Comment:</em></td><td><?echo htmlentities($interface->get_comment());?></td></tr>
		</table>
		<!--<img class="system_image" src=<?#echo base_url() . $this->impulselib->get_os_img_path($system->get_os_name())?>></img>-->
		<div class="infobar">
			<span class="infobar_text">Created on <?echo htmlentities($interface->get_date_created());?> - Modified by <?echo htmlentities($interface->get_last_modifier());?> on <?echo htmlentities($interface->get_date_modified());?></span>
		</div>
	</div>
</div>