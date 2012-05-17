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
			echo "<td class=\"$class\"><a href=\"/firewall/metahost_rule/view/".rawurlencode($mHost->get_name())."/".rawurlencode($rule->get_transport())."/".rawurlencode($rule->get_port())."\">".htmlentities($rule->get_port())."</a></td>";
			if(($i+1) % $cells_per_row == 0) {
				echo "</tr>";
			}
			$i++;
		}
		?>
	</table>
</div>