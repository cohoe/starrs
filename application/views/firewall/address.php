<div class="item_container">
	<table class="item_information_area_table">
		<?
		$i = 0;
		$cells_per_row = 8;
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
            else {
                $class = "firewall_rule_port_box_unknown";
            }
			echo "<td class=\"$class\"><a href=\"/firewall/rule/view/".rawurlencode($addr->get_address())."/".rawurlencode($rule->get_transport())."/".rawurlencode($rule->get_port())."/\">".htmlentities($rule->get_port())."</a></td>";
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
		<tr><td class="<?echo $class;?>" colspan="<?echo $cells_per_row;?>"><a href="/firewall/rules/action/<?echo rawurlencode($addr->get_address());?>"><?echo htmlentities($message);?></a></td></tr>
	</table>
</div>