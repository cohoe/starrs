<div class="item_container">
	<img class="system_image" src=<?echo base_url() . $this->impulselib->get_os_img_path($system->get_os_name())?>></img>

	<table class="item_information_area_table">
		<tr><td><em>Owner:</em></td><td><?echo htmlentities($system->get_owner());?></td></tr>
		<tr><td><em>Type:</em></td><td><?echo htmlentities($system->get_type());?></td></tr>
		<tr><td><em>OS:</em></td><td><?echo htmlentities($system->get_os_name());?></td></tr>
		<tr><td><em>Comment:</em></td><td><?echo htmlentities($system->get_comment());?></td></tr>
		<tr><td><em>Renew Date:</em></td><td><?echo htmlentities($system->get_renew_date());?></td></tr>
	</table>
</div>
<div class="infobar">
	<span class="infobar_text">Created on <?echo htmlentities($system->get_date_created());?> - Modified by <?echo htmlentities($system->get_last_modifier());?> on <?echo htmlentities($system->get_date_modified());?></span>
</div>
