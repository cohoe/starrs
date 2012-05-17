<div class="item_container">
	<table class="item_information_area_table">
		<tr><td><em>Comment:</em></td><td><?echo htmlentities($mHost->get_comment());?></td></tr>
		<tr><td><em>Owner:</em></td><td><?echo htmlentities($mHost->get_owner());?></td></tr>
	</table>
</div>
<div class="infobar">
	<span class="infobar_text">Created on <?echo htmlentities($mHost->get_date_created());?> - Modified by <?echo htmlentities($mHost->get_last_modifier());?> on <?echo htmlentities($mHost->get_date_modified());?></span>
</div>