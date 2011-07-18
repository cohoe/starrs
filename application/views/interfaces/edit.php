<div class="item_container">
	<form method="POST" class="input_form">
		<label for="mac">MAC: </label><input type="text" name="mac" value="<?echo $interface->get_mac()?>" class="input_form_input" /><br />
		<label for="systemName">System Name: </label><select name="systemName" class="input_form_input">
		<?
			foreach ($systems as $system) {
				if($interface->get_system_name() == $system) {
					echo "<option value=\"$system\" selected=\"selected\">$system</option>";
				}
				else {
					echo "<option value=\"$system\">$system</option>";
				}
			}
		?>
		</select><br />
		<label for="name">Interface Name: </label><input type="text" name="name" value="<?echo $interface->get_interface_name()?>" class="input_form_input" /><br />
		<label for="comment">Comment: </label><input type="text" name="comment" value="<?echo $interface->get_comment();?>" class="input_form_input" /><br />
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Save" class="input_form_submit"/>
	</form>
</div>