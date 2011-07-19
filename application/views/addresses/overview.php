<div class="item_container">
	<table class="item_information_area_table">
		<tr><td><em>Address:</em></td><td><?echo htmlentities($address->get_address());?></td></tr>
		<tr><td><em>Interface MAC:</em></td><td><a href="/interfaces/addresses/<?echo $address->get_mac();?>"><?echo htmlentities($address->get_mac());?></a></td></tr>
		<tr><td><em>Family:</em></td><td><?echo htmlentities("IPv".$address->get_family());?></td></tr>
		<tr><td><em>Range:</em></td><td><?echo htmlentities($address->get_range());?></td></tr>
		<tr><td><em>Configuration:</em></td><td><?echo htmlentities($address->get_config());?></td></tr>
		<tr><td><em>Class:</em></td><td><?echo htmlentities($address->get_class());?></td></tr>
		<tr><td><em>Primary?:</em></td><td><?echo htmlentities(($address->get_isprimary() == 't') ? "True" : "False");?></td></tr>
		<tr><td><em>Comment:</em></td><td><?echo htmlentities($address->get_comment());?></td></tr>
	</table>
</div>
<div class="infobar">
	<span class="infobar_text">Created on <?echo $address->get_date_created();?> - Modified by <?echo $address->get_last_modifier();?> on <?echo $address->get_date_modified();?></span>
</div>
