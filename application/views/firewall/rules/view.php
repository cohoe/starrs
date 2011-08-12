<div class="item_information_area">
	<div class="interface_box">
		<table class="item_information_area_table">
			<tr><td><em>Port:</em></td><td><?echo htmlentities($fwRule->get_port());?></td></tr>
			<tr><td><em>Transport:</em></td><td><?echo htmlentities($fwRule->get_transport());?></td></tr>
			<tr><td><em>Deny?:</em></td><td><?echo htmlentities($fwRule->get_deny());?></td></tr>
			<tr><td><em>Comment:</em></td><td><?echo htmlentities($fwRule->get_comment());?></td></tr>
			<tr><td><em>Owner:</em></td><td><?echo htmlentities($fwRule->get_owner());?></td></tr>
			<tr><td><em>Source:</em></td><td><?echo htmlentities($fwRule->get_source());?></td></tr>
		</table>
		<div class="infobar">
			<span class="infobar_text">Created on <?echo htmlentities($fwRule->get_date_created());?> - Modified by <?echo htmlentities($fwRule->get_last_modifier());?> on <?echo htmlentities($fwRule->get_date_modified());?></span>
		</div>
	</div>
</div>