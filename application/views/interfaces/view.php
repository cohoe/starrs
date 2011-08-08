<div class="item_container">
    <table class="item_information_area_table">
		<tr><td><em>System Name:</em></td><td><a href="/systems/view/<?echo rawurlencode(htmlentities($int->get_system_name()));?>"><?echo htmlentities($int->get_system_name());?></a></td></tr>
        <tr><td><em>Name:</em></td><td><?echo $int->get_interface_name();?></td></tr>
        <tr><td><em>MAC:</em></td><td><?echo $int->get_mac();?></td></tr>
        <tr><td><em>Comment:</em></td><td><?echo $int->get_comment();?></td></tr>
    </table>
</div>
<div class="infobar">
	<span class="infobar_text">Created on <?echo $int->get_date_created();?> - Modified by <?echo $int->get_last_modifier();?> on <?echo $int->get_date_modified();?></span>
</div>