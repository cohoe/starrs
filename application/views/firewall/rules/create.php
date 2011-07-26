<div class="item_container">
	<form method="POST" class="input_form">
		<label for="program">Program: </label>
		<select name="program" class="input_form_input">
			<option selected></option>
			<? foreach ($fwProgs as $fwProg) {
				echo "<option value=\"".$fwProg->get_name()."\">".$fwProg->get_name()." (".$fwProg->get_port()."-".$fwProg->get_transport().")</option>";
			} ?>
		</select><br />
		<div style="float: right; width: 100%; text-align: center; font-weight: bold;">-OR-</div>
		<label for="port">Port: </label><input type="text" name="port" class="input_form_input" /><br />
		<label for="transport">Transport: </label>
		<select name="transport" class="input_form_input">
			<option selected></option>
			<? foreach ($transports as $transport) {
				echo "<option value=\"$transport\">$transport</option>";
			} ?>
		</select><br />
		<label for="comment">Comment: </label><input type="text" name="comment" class="input_form_input" /><br /><br />
		<label for="text">Deny?: </label>
			<input type="radio" name="deny" value="t" class="input_form_radio" <?echo ($addr->get_fw_default() == 'f')?"checked":"";?> />Yes
			<input type="radio" name="deny" value="f" class="input_form_radio" <?echo ($addr->get_fw_default() == 't')?"checked":"";?> />No<br />
		<? if(isset($admin)) {?>
			<label for="owner">Owner: </label><input type="text" name="owner" value="<?echo $user;?>" class="input_form_input" /><br />
		<?} else {?>
			<input type="text" name="owner" value="<?echo $user;?>" class="input_form_input" readonly /><br />
		<?}?>
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Create" class="input_form_submit"/>
	</form>
</div>