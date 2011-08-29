<div class="item_container">
	<form method="POST" class="input_form">
		<label for="systemName">System Name: </label><input type="text" name="systemName" class="input_form_input" /><br />
		<label for="type">Type: </label><select name="type" class="input_form_input">
			<option selected></option>
		<?
			foreach ($systemTypes as $type) {
				echo "<option value=\"$type\">".$type."</option>";
			}
		?>
		</select><br />
		<label for="osName">Operating System: </label><select name="osName" class="input_form_input">
			<option selected></option>
		<?
			foreach ($operatingSystems as $os) {
				echo "<option value=\"$os\">".$os."</option>";
			}
		?>
		</select><br />
		<label for="comment">Comment: </label><input type="text" name="comment" class="input_form_input" /><br />
		
		<label for="owner">Owner: </label><input type="text" name="owner" value="<?echo $user;?>" class="input_form_input" <?=(isset($isadmin)?'disabled="disabled"':'');?>/><br />
		
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Create System" class="input_form_submit" class="input_form_input" />
	</form>

</div>
