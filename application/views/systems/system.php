<div class="item_container">
	<a href=<?echo base_url() . "systems/view/" . $system->get_system_name();?>>
	<div class="resource_title_bar_style4">
		<span class="resource_title_bar_left"><?echo $system->get_system_name(); if ($system->get_comment()) { $comment = $system->get_comment(); echo " ($comment)"; }?></span>
		<img class="system_image" src=<?echo base_url() . $this->impulselib->get_os_img_path($system->get_os_name())?>></img>
	</div>
	</a>

	<div class="item_information_area_style4">
		<table class="item_information_area_table">
			<tr><td><em>Owner:</em></td><td><?echo $system->get_owner();?></td></tr>
			<tr><td><em>Type:</em></td><td><?echo $system->get_type();?></td></tr>
			<tr><td><em>OS:</em></td><td><?echo $system->get_os_name();?></td></tr>
		</table>
       
	</div>

	<div class="item_lower_bar_style4">Created on <?echo $system->get_date_created();?> - Modified by <?echo $system->get_last_modifier();?> on <?echo $system->get_date_modified();?></div>
</div>
