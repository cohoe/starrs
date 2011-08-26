<div class="item_container">
	<form method="POST" class="input_form">
		<label for="systemName">System Name: </label><input type="text" name="systemName" class="input_form_input" /><br />
		<label for="mac">MAC Address: </label><input type="text" name="mac" class="input_form_input" /><br />
		<label for="ipaddress">IP Address: </label><input type="text" name="ipaddress" class="input_form_input" /><br />
		<label for="range">Range: </label><select name="range" class="input_form_input">
			<option selected></option>
		<?  foreach ($ranges as $range) {
				echo "<option value=\"{$range->get_name()}\">{$range->get_name()}</option>";
			}   ?>
		</select><br />
		<label for="hostname">Hostname: </label><input type="text" name="hostname" class="input_form_input" /><br />
		<label for="zone">Zone: </label><select name="zone" class="input_form_input">
			<option selected></option>
		<?  foreach ($zones as $zone) {
				echo "<option value=\"{$zone->get_zone()}\">{$zone->get_zone()}</option>";
			}   ?>
		</select><br />
		<label for="owner">Owner: </label><input type="text" name="owner" class="input_form_input" /><br />
		<label for="lastmodifier">Last Modifier: </label><input type="text" name="lastmodifier" class="input_form_input" /><br />
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Search" class="input_form_submit"/>
	</form>
</div>