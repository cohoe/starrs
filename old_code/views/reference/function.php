<div class="item_container">
	<div class="resource_title_bar_style4">
		<span class="resource_title_bar_left"><?php echo $name;?></span>
	</div>
	<div class="item_information_area_style4">
		<table class="item_information_area_table">
			<tr><td><em>Description:</em></td><td><?php echo $comment;?></td></tr>
			<tr><td><em>Returns:</em></td><td><?php echo $returns;?></td></tr>
			<tr><td><em>Arguments:</em></td><td><ul>
			<?
			foreach ($args as $arg)
			{
				echo "<li>$arg[argument] - $arg[comment]</li>";
			}
			?>
			</ul></td></tr>
			<tr><td><em>Example:</em></td><td><?php echo $example;?></td></tr>
		</table>
	</div>
	<div class="item_lower_bar_style4"></div>
</div>
