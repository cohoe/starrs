<div class="item_container">
	<form method="POST" class="input_form">
		<label for="systemName">System Name: </label><input type="text" name="systemName" class="input_form_input" /><br />
		<label for="osName">Operating System: </label><select name="osName" class="input_form_input">
		<option selected></option>
		<?
			foreach ($operatingSystems as $os) {
				echo "<option value=\"$os\">".$os."</option>";
			}
		?>
		</select><br />
		<label for="mac">MAC: </label><input type="text" name="mac" class="input_form_input" /><br /><br />
		<label for="range">Range: </label><select name="range" class="input_form_input">
			<option selected></option>
			<? foreach ($ranges as $range) {
				echo "<option value=\"".$range->get_name()."\">".$range->get_name()."</option>";
			} ?>
		</select><br/>
		<div style="float: right; width: 100%; text-align: center;">-OR-</div>
		<br/>
		<label for="address">Address: </label><input type="text" name="address" class="input_form_input" /><br />
		<label for="owner">Owner: </label><input type="text" name="owner" value="<?=$user;?>" <?=(isset($isadmin))?"readonly":""?>><br />
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Create System" class="input_form_submit" class="input_form_input" />
	</form>

</div>
