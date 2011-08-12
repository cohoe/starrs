<?php
    $fqdn = $address->get_fqdn();
    if(!$fqdn) {
        $fqdn = "No FQDN could be found for this IP address";
    }
?>
<div class="item_container">
	<div class="item_title_style2">
		<span class="item_title_bar_left"><?echo htmlentities($address->get_comment());?></span>
		<? if ($address->get_isprimary() == 't') {?>
		<span class="item_title_bar_right">Primary</span>
		<?}?>
	</div>
	<div class="item_information_area_style2">
		<table class="item_information_area_table">
			<tr><td><em>Address:</em></td><td><?echo htmlentities($address->get_address());?></td></tr>
			<tr><td><em>DNS Name:</em></td><td><?echo htmlentities($fqdn);?></td></tr>
			<tr><td><em>Configuration:</em></td><td><?echo htmlentities($address->get_config());?></td></tr>
			<tr><td><em>Class:</em></td><td><?echo htmlentities($address->get_class());?></td></tr>
		</table>
	</div>
	<div class="item_lower_bar_style2">Created on <?echo htmlentities($address->get_date_created());?> - Modified by <?echo htmlentities($address->get_last_modifier());?> on <?echo htmlentities($address->get_date_modified());?></div>
</div>
