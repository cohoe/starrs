<div class="item_container">
	<form method="POST" class="input_form">
		<label for="mac">Interface: </label><input type="text" name="mac" value="<?echo $interface->get_mac();?>" disabled="disabled" class="input_form_input" /><br />
		<label for="range">Range: </label><select name="range" class="input_form_input">
			<? foreach ($ranges as $range) {
				echo "<option value=\"$range[name]\">$range[name]</option>";
			} ?>
		</select></br>
		<div style="float: right; width: 100%; text-align: center;">-OR-</div>
		</br>
		<label for="address">Address: </label><input type="text" name="address" class="input_form_input" /><br />
		<label for="config">Configuration: </label><select name="config" class="input_form_input">
			<? foreach ($configs as $config) {
				echo "<option value=\"$config[config]\">$config[config]</option>";
			} ?>
		</select><br />
		<label for="class">Class: </label><select name="class" class="input_form_input">
			<? foreach ($classes as $class) {
				echo "<option value=\"$class[class]\">$class[class]</option>";
			} ?>
		</select><br />
		
		<label for="isprimary">Primary Address?: </label>
		<input type="radio" name="isprimary" value="t" class="input_form_radio" checked />Yes
		<input type="radio" name="isprimary" value="f" class="input_form_radio" />No
		<label for="comment">Comment: </label><input type="text" name="comment" class="input_form_input" /><br />
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Create" class="input_form_submit"/>
	</form>
</div>