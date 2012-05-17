<div class="item_container">
	<div class="item_title_style1">
		<span class="item_title_bar_left">Firewall Rules <?echo "($address)";?></span>
	</div>
	<div class="item_information_area_style1">
		<table class="item_information_area_table">
			<?
			$i = 0;
			$cells_per_row = 5;
			$class;
			foreach ($rules as $rule) {				
				if($i % $cells_per_row == 0) {
					echo "<tr>";
				}
				if($rule->get_deny() == 't') {
					$class = "firewall_rule_port_box_deny";
				}
				elseif($rule->get_deny() == 'f') {
					$class = "firewall_rule_port_box_allow";
				}
				echo "<td class=\"$class\">".$rule->get_port()."</td>";
				if(($i+1) % $cells_per_row == 0) {
					echo "</tr>";
				}
				$i++;
			}

			$message;
			if($deny == 't') {
				$message = "Deny all";
				$class = "firewall_rule_default_box_deny";
			}
			elseif($deny == 'f') {
				$message = "Allow all";
				$class = "firewall_rule_default_box_allow";
			}
			else {
				$message = "No default action";
				$class = "firewall_rule_default_box_unknown";
			}
			?>
			<tr><td class="<?echo $class;?>" colspan="<?echo $cells_per_row;?>"><?echo $message;?></td></tr>
		</table>
	</div>
	<div class="item_lower_bar_style1"></div>
</div>
