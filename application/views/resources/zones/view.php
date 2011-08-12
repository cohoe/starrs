<div class="item_container">
	<table class="item_information_area_table">
		<tr><td><em>Zone:</em></td><td><?echo htmlentities($dnsZone->get_zone());?></td></tr>
		<tr><td><em>DNS Key:</em></td><td><a href="/resources/keys/view/<?echo rawurlencode($dnsZone->get_keyname());?>"><?echo htmlentities($dnsZone->get_keyname());?></a></td></tr>
		<tr><td><em>Forward?:</em></td><td><?echo ($dnsZone->get_forward() == 't')?"Yes":"No";?></td></tr>
		<tr><td><em>Shared?:</em></td><td><?echo ($dnsZone->get_shared() == 't')?"Yes":"No";?></td></tr>
		<tr><td><em>Owner:</em></td><td><?echo htmlentities($dnsZone->get_owner());?></td></tr>
		<tr><td><em>Comment:</em></td><td><?echo htmlentities($dnsZone->get_comment());?></td></tr>
	</table>
</div>
<div class="infobar">
	<span class="infobar_text">Created on <?echo htmlentities($dnsZone->get_date_created());?> - Modified by <?echo htmlentities($dnsZone->get_last_modifier());?> on <?echo htmlentities($dnsZone->get_date_modified());?></span>
</div>