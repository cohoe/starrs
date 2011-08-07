<div class="item_container">
    <table class="item_information_area_table">
		<?
		$i = 0;
		$cells_per_row = 10;
		$class = "firewall_rule_port_box_unknown";
        if($sPort->get_state() == 't') {
            $class = "firewall_rule_port_box_allow";
        }
        elseif($sPort->get_state() == 'f') {
            $class = "firewall_rule_port_box_deny";
        }
        else {
            $class = "firewall_rule_port_box_unknown";
        }

		foreach ($sPorts as $sPort) {
			if($i % $cells_per_row == 0) {
				echo "<tr>";
			}
			echo "<td class=\"$class\"><a href=\"/switchport/view/".rawurlencode($sPort->get_system_name())."/".rawurlencode($sPort->get_port_name())."\">".htmlentities($sPort->get_port_name())."</a></td>";
			if(($i+1) % $cells_per_row == 0) {
				echo "</tr>";
			}
			$i++;
		}
		?>
	</table>
    <? foreach ($sPorts as $sPort) {?>
        <div style="border: 1px solid black; margin: 1px; width: 48px; height: 48px; float: left;"><?echo $sPort->get_port_name();?></div>
    <?} ?>
</div>