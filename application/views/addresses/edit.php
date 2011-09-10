<div class="item_container">
	<form method="POST" class="input_form">
		<label for="mac">Interface: </label><input type="text" name="mac" value="<?echo $addr->get_mac();?>" disabled="disabled" class="input_form_input" /><br />
		<br/>
		<?
			if($addr->get_dynamic() ==  TRUE) {
				#echo "<label for=\"address\">Address: </label><input type=\"text\" name=\"address\" value=\"Dynamic\" class=\"input_form_input\" disabled />";
				echo "<input type=\"hidden\" name=\"address\" value=\"".$addr->get_address()."\" />";
			}
			else {?>
			
		<label for="range">Range: </label><select name="range" class="input_form_input">
			<? foreach ($ranges as $range) {
				if($addr->get_range() == $range->get_name()) {
					echo "<option value=\"".$range->get_name()."\" selected=\"selected\">".$range->get_name()."</option>";
				}
				else {
					echo "<option value=\"".$range->get_name()."\">".$range->get_name()."</option>";
				}
			} ?>
		</select><br/>
		<div style="float: right; width: 100%; text-align: center;">-OR-</div>
<?
				echo "<label for=\"address\">Address: </label><input type=\"text\" name=\"address\" value=\"".$addr->get_address()."\" class=\"input_form_input\" />";
			}
		?>		
		<br />
		<label for="config">Configuration: </label><select name="config" class="input_form_input">
			<? if($addr->get_dynamic() == TRUE) {
				echo "<option value=\"".$addr->get_config()."\" selected=\"selected\" >".$addr->get_config()."</option>";
			}
			else {
				foreach ($configs as $config) {
					if($addr->get_config() == $config->get_config()) {
						echo "<option value=\"".$config->get_config()."\" selected=\"selected\" >".$config->get_config()."</option>";
					}
					else {
						echo "<option value=\"".$config->get_config()."\">".$config->get_config()."</option>";
					}
				} 
			}?>
		</select><br />
		<label for="class">Class: </label><select name="class" class="input_form_input">
			<? foreach ($classes as $class) {
				if($addr->get_class() == $class->get_class()) {
					echo "<option value=\"".$class->get_class()."\" selected=\"selected\">".$class->get_class()."</option>";
				}
				else {
					echo "<option value=\"".$class->get_class()."\">".$class->get_class()."</option>";
				}
			} ?>
		</select><br />
		
		
		<label for="isprimary">Primary Address?: </label>
		<input type="radio" name="isprimary" value="t" class="input_form_radio" <?echo ($addr->get_isprimary() == 't' ) ? "checked":"";?>/>Yes
		<input type="radio" name="isprimary" value="f" class="input_form_radio" <?echo ($addr->get_isprimary() == 'f')? "checked":"";?>/>No
		<br />
		<label for="comment">Comment: </label><input type="text" name="comment" value="<?echo $addr->get_comment();?>" class="input_form_input" /><br />
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Save" class="input_form_submit"/>
	</form>
</div>
