<div class="function_container">
	<div class="function_title">
		<span class="function_title_span"><?php echo $name;?></span>
	</div>
	
	<div class="function_information">
		<table>
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
	
	<div class="function_lower_bar"></div>
</div>
