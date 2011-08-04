<div class="item_container">
	<form method="POST" class="input_form">
		<label for="text">Deny?: </label>
			<input type="radio" name="deny" value="t" class="input_form_radio" <?echo ($addr->get_fw_default() == 't')?"checked":"";?> />Yes
			<input type="radio" name="deny" value="f" class="input_form_radio" <?echo ($addr->get_fw_default() == 'f')?"checked":"";?> />No<br />
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Save" class="input_form_submit"/>
	</form>
</div>