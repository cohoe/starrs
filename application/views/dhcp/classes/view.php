<div class="item_container">
    <table class="item_information_area_table">
		<tr><td><em>Class:</em></td><td><?echo htmlentities($class->get_class());?></td></tr>
		<tr><td><em>Comment:</em></td><td><?echo htmlentities($class->get_comment());?></td></tr>
	</table>
</div>
<div class="infobar">
	<span class="infobar_text">Created on <?echo htmlentities($class->get_date_created());?> - Modified by <?echo htmlentities($class->get_last_modifier());?> on <?echo htmlentities($class->get_date_modified());?></span>
</div>