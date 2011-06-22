<div class="item_container">
	<div class="item_title_style1">
		<span class="item_title_bar_left">Standalone Programs</span>
	</div>
	<div class="item_information_area_style1">
		<table class="item_information_area_table">
			<tr><th>Program</th><th>Deny</th></tr>
			<?
			foreach ($stdprogs as $rule)
			{
				echo "<tr><td>$rule[name]</td><td>$rule[deny]</td></tr>";
			}
			?>
		</table>
	</div>
	<div class="item_lower_bar_style1"></div>
</div>
