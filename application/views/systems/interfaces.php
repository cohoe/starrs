<div class="item_container">
	<!--<img class="system_image" src=<?#echo base_url() . $this->impulselib->get_os_img_path($system->get_os_name())?>></img>-->

	<? if(isset($none)) {?>
		No interfaces found!
	<?}
	else {?>
	<table class="item_information_area_table">
		<tr><td><em>Name:</em></td><td><?echo $interface->get_interface_name();?></td></tr>
		<tr><td><em>MAC:</em></td><td><?echo $interface->get_mac();?></td></tr>
		<tr><td><em>Comment:</em></td><td><?echo $interface->get_comment();?></td></tr>
		<tr><td><em>Date Created:</em></td><td><?echo $interface->get_date_created();?></td></tr>
		<tr><td><em>Date Modified:</em></td><td><?echo $interface->get_date_modified();?></td></tr>
		<tr><td><em>Last Modifier:</em></td><td><?echo $interface->get_last_modifier();?></td></tr>
	</table>
	<?}?>

</div>
