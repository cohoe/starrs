<title>Testing</title>
<div class="item_container">
	<form method="POST" class="create_form">
		<label for="mac">Interface: </label><input type="text" name="mac" value="<?echo $interface->get_mac();?>" disabled="disabled" /><br />
		<label for="range">Range: </label><select name="range">
			<? foreach ($ranges as $range) {
				echo "<option value=\"$range[name]\">$range[name]</option>";
			} ?>
		</select></br>
		<span style="float: right; font-weight: bold;">-OR-</span>
		</br>
		<label for="address">Address: </label><input type="text" name="address" /><br />
		<label for="config">Configuration: </label><select name="config">
			<? foreach ($configs as $config) {
				echo "<option value=\"$config[config]\">$config[config]</option>";
			} ?>
		</select><br />
		<label for="class">Class: </label><select name="class">
			<? foreach ($classes as $class) {
				echo "<option value=\"$class[class]\">$class[class]</option>";
			} ?>
		</select><br />
		
		<label for="isprimary">Primary Address?: </label><input type="checkbox" name="isprimary" value="True" checked="checked" ><br />
		<label for="comment">Comment: </label><input type="text" name="comment" /><br />
		<input type="submit" name="submit" value="Create" class="submit"/>
	</form>
</div>
