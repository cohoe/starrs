<div class="item_container">
	<div class="interface_box">
		<div class="interface_box_nav">
			<? echo htmlentities($membr->get_address());?>
			<a href="/members/delete/<?echo rawurlencode($membr->get_name())."/".rawurlencode($membr->get_address());?>"><div class="nav_item_right"><span>Delete</span></div></a>
		</div>
		<div class="infobar">
			<span class="infobar_text">Created on <?echo htmlentities($membr->get_date_created());?> - Modified by <?echo htmlentities($membr->get_last_modifier());?> on <?echo htmlentities($membr->get_date_modified());?></span>
		</div>
	</div>
</div>