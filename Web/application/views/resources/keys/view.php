<div class="item_container">
	<table class="item_information_area_table">
		<tr><td><em>Key Name:</em></td><td><?echo htmlentities($dnsKey->get_keyname());?></td></tr>
		<tr><td><em>Key:</em></td><td><?echo htmlentities($dnsKey->get_key());?></td></tr>
		<tr><td><em>Owner:</em></td><td><?echo htmlentities($dnsKey->get_owner());?></td></tr>
		<tr><td><em>Comment:</em></td><td><?echo htmlentities($dnsKey->get_comment());?></td></tr>
	</table>
</div>
<div class="infobar">
	<span class="infobar_text">Created on <?echo htmlentities($dnsKey->get_date_created());?> - Modified by <?echo htmlentities($dnsKey->get_last_modifier());?> on <?echo htmlentities($dnsKey->get_date_modified());?></span>
</div>