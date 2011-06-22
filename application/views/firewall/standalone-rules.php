<div class="item_container">
	<div class="item_title_style1">
		<span class="item_title_bar_left">Standalone Rules</span>
	</div>
	<div class="item_information_area_style1">
		<table class="item_information_area_table">
			<tr><th>Port</th><th>Transport</th><th>Deny</th></tr>
			<?
			foreach ($stdrules as $rule)
			{
				echo "<tr><td>$rule[port]</td><td>$rule[transport]</td><td>$rule[deny]</td></tr>";
			}
			?>
		</table>
	</div>
	<div class="item_lower_bar_style1"></div>
</div>
