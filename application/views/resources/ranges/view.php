<div class="item_container">
	<table class="item_information_area_table">
		<tr><td><em>Name:</em></td><td><?echo htmlentities($ipRange->get_name());?></td></tr>
		<tr><td><em>First IP:</em></td><td><?echo htmlentities($ipRange->get_first_ip());?></td></tr>
		<tr><td><em>Last IP:</em></td><td><?echo htmlentities($ipRange->get_last_ip());?></td></tr>
		<tr><td><em>Subnet:</em></td><td><a href="/resources/subnets/view/<?echo htmlentities(rawurlencode($ipRange->get_subnet()));?>"><?echo htmlentities($ipRange->get_subnet());?></a></td></tr>
		<tr><td><em>Use Code:</em></td><td><?echo htmlentities($ipRange->get_use());?></td></tr>
		<tr><td><em>DHCP Class:</em></td><td><a href="/dhcp/classes/view/<?echo htmlentities(rawurlencode($ipRange->get_class()));?>"><?echo htmlentities($ipRange->get_class());?></a></td></tr>
		<tr><td><em>Comment:</em></td><td><?echo htmlentities($ipRange->get_comment());?></td></tr>
	</table>
</div>
<div class="infobar">
	<span class="infobar_text">Created on <?echo htmlentities($ipRange->get_date_created());?> - Modified by <?echo htmlentities($ipRange->get_last_modifier());?> on <?echo htmlentities($ipRange->get_date_modified());?></span>
</div>