<div class="item_container">
	<form method="POST" class="input_form">
		<label for="mac">Interface: </label><input type="text" name="mac" value="<?echo $addr->get_mac();?>" disabled="disabled" /><br />
		<label for="range">Range: </label><select name="range">
			<? foreach ($ranges as $range) {
				if($addr->get_range() == $range['name']) {
					echo "<option value=\"$range[name]\" selected=\"selected\">$range[name]</option>";
				}
				else {
					echo "<option value=\"$range[name]\">$range[name]</option>";
				}
			} ?>
		</select></br>
		<div style="float: right; width: 100%; text-align: center;">-OR-</div>
		</br>
		<label for="address">Address: </label><input type="text" name="address" value="<?echo $addr->get_address();?>" /><br />
		<label for="config">Configuration: </label><select name="config">
			<? foreach ($configs as $config) {
				if($addr->get_config() == $config['config']) {
					echo "<option value=\"$config[config]\" selected=\"selected\" >$config[config]</option>";
				}
				else {
					echo "<option value=\"$config[config]\">$config[config]</option>";
				}
			} ?>
		</select><br />
		<label for="class">Class: </label><select name="class">
			<? foreach ($classes as $class) {
				if($addr->get_class() == $class['class']) {
					echo "<option value=\"$class[class]\" selected=\"selected\">$class[class]</option>";
				}
				else {
					echo "<option value=\"$class[class]\">$class[class]</option>";
				}
			} ?>
		</select><br />
		
		
		<label for="isprimary">Primary Address?: </label>
		<input type="radio" name="isprimary" value="t" class="input_form_radio" <?echo ($addr->get_isprimary() == 't' ) ? "checked":"";?>/>Yes
		<input type="radio" name="isprimary" value="f" class="input_form_radio" <?echo ($addr->get_isprimary() == 'f')? "checked":"";?>/>No
		<label for="comment">Comment: </label><input type="text" name="comment" value="<?echo $addr->get_comment();?>" /><br />
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Save" class="input_form_submit"/>
	</form>
</div>