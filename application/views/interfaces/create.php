<title>Testing</title>
<div class="item_container">
	<form method="POST" class="create_form">
	
		<label for="mac">MAC: </label><input type="text" name="mac"/><br />
	
		<label for="systemName">System Name: </label><select name="systemName">
		<?
			foreach ($systems as $system) {
				if($systemName == $system) {
					echo "<option value=\"$system\" selected=\"selected\">$system</option>";
				}
				else {
					echo "<option value=\"$system\">$system</option>";
				}
			}
		?>
		</select><br />
		
		<label for="name">Interface Name: </label><input type="text" name="name" /><br />
		<label for="comment">Comment: </label><input type="text" name="comment" /><br />
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Save" class="submit"/>
	</form>
</div>