<?
$macaddrs = $sPort->get_mac_addresses();
?>
<div class="item_information_area">
	<div class="interface_box">
		<table class="item_information_area_table">
			<tr><td><em>System Name:</em></td><td><?echo $sPort->get_system_name();?></td></tr>
			<tr><td><em>Port Name:</em></td><td><?echo $sPort->get_port_name();?></td></tr>
			<tr><td><em>Type:</em></td><td><?echo $sPort->get_type();?></td></tr>
			<tr><td><em>Description:</em></td><td><?echo $sPort->get_description();?></td></tr>
            <?if($sys->get_switchview_enable()=='t') {?>
			    <tr><td><em>Current State:</em></td><td><?echo ($sPort->get_port_state()=='t')?"Active":"Inactive";?></td></tr>
			    <tr><td><em>Administrative State:</em></td><td><?echo ($sPort->get_admin_state()=='t')?"Enabled":"Disabled";?></td></tr>
                <tr><td><em>Attached MAC Addresses:</em></td><td><?echo ($macaddrs)?array_shift($macaddrs):"";?></td></tr>
            <?  foreach($macaddrs as $mac) {
                    echo "<tr><td></td><td>$mac</td></tr>";
                }
            }?>
		</table>
		<div class="infobar">
			<span class="infobar_text">Created on <?echo $sPort->get_date_created();?> - Modified by <?echo $sPort->get_last_modifier();?> on <?echo $sPort->get_date_modified();?></span>
		</div>
	</div>
</div>