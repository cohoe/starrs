<div class="item_container">
	<form method="POST" class="input_form">
		<label for="type">Record Type: </label><input type="text" name="type" value="<?echo $record->get_type();?>" class="input_form_input" readonly />
		<label for="address">Address: </label><input type="text" name="address" value="<?echo $record->get_address();?>" class="input_form_input" readonly />
		<label for="hostname">Hostname: </label><input type="text" name="hostname" class="input_form_input" value="<?echo $record->get_hostname();?>" /><br>
		<label for="zone">Domain: </label>
		<select name="zone" class="input_form_input">
			<? foreach ($zones as $zone) {
				if($zone ==  $record->get_zone()) {
					echo "<option value=\"$zone\" selected>$zone</option>";
				}
				else {
					echo "<option value=\"$zone\">$zone</option>";
				}
			} ?>
		</select><br />
		<label for="text">Primary?: </label>
			<input type="radio" name="isprimary" value="t" class="input_form_radio" <?echo ($record->get_isprimary() == 't')?"checked":"";?> />Yes
			<input type="radio" name="isprimary" value="f" class="input_form_radio" <?echo ($record->get_isprimary() == 'f')?"checked":"";?> />No
		<label for="ttl">TTL: </label><input type="ttl" name="ttl" class="input_form_input" value="<?echo $record->get_ttl();?>" />
		<?
		// Owner input
		if(isset($admin)) {?>
			<label for="owner">Owner: </label><input type="text" name="owner" value="<?echo $record->get_owner();?>" class="input_form_input" />
		<?}
		else {?>
			<input type="text" name="owner" value="<?echo $record->get_owner();?>" class="input_form_input" hidden="true" />
		<?}
		
		// Submit button
		?>
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Save" class="input_form_submit"/>
	</form>
</div>