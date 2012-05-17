<div class="item_container">
	<div class="resource_title_bar_style4">
		<span class="resource_title_bar_left"><?echo htmlentities($name);?></span>
	</div>
	<div class="item_information_area_style4">
		<table class="item_information_area_table">
			<tr><td><em>Description:</em></td><td><?echo htmlentities($comment);?></td></tr>
			<tr><td><em>Returns:</em></td><td><?echo htmlentities($returns);?></td></tr>
			<tr><td><em>Arguments:</em></td><td><ul>
			<?
			foreach ($args as $arg)
			{
				echo '<li>'.htmlentities($arg['argument']).' - '.htmlentities($arg['comment']).'</li>';
			}
			?>
			</ul></td></tr>
			<tr><td><em>Example:</em></td><td><?echo htmlentities($example);?></td></tr>
		</table>
	</div>
	<div class="item_lower_bar_style4"></div>
</div>
