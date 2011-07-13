<div class="item_container">
	<img class="system_image" src=<?echo base_url() . $this->impulselib->get_os_img_path($system->get_os_name())?>></img>

	<table class="item_information_area_table">
		<tr><td><em>Owner:</em></td><td><?echo $system->get_owner();?></td></tr>
		<tr><td><em>Type:</em></td><td><?echo $system->get_type();?></td></tr>
		<tr><td><em>OS:</em></td><td><?echo $system->get_os_name();?></td></tr>
		<tr><td><em>Comment:</em></td><td><?echo $system->get_comment();?></td></tr>
		<tr><td><em>Date Created:</em></td><td><?echo $system->get_date_created();?></td></tr>
		<tr><td><em>Date Modified:</em></td><td><?echo $system->get_date_modified();?></td></tr>
		<tr><td><em>Last Modifier:</em></td><td><?echo $system->get_last_modifier();?></td></tr>
	</table>

</div>
