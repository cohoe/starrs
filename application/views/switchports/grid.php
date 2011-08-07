<div class="item_container">
    <table class="item_information_area_table">
		<?
		$i = 0;
		$cells_per_row = 8;
		$class = "firewall_rule_port_box_unknown";
		foreach ($sPorts as $sPort) {
			if($i % $cells_per_row == 0) {
				echo "<tr>";
			}
			echo "<td class=\"$class\"><a href=\"/switchport/view/".$sPort->get_system_name()."/".$sPort->get_port_name()."\">".$sPort->get_port_name()."</a></td>";
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