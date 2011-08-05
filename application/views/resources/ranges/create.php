<div class="item_container">
	<form method="POST" class="input_form">
		<label for="name">Name: </label><input type="text" name="name" class="input_form_input" /><br />
		<label for="first_ip">First IP: </label><input type="text" name="first_ip" class="input_form_input" /><br />
		<label for="last_ip">Last IP: </label><input type="text" name="last_ip" class="input_form_input" /><br />
		<label for="subnet">Subnet: </label><select name="subnet">
			<option></option>
			<?foreach($sNets as $sNet) {
				echo "<option value=\"".$sNet->get_subnet()."\">".$sNet->get_subnet()."</option>";
			}?>
		</select><br />
		<label for="use">Use Code: </label><select name="use">
			<option></option>
			<?foreach($uses as $use) {
				echo "<option value=\"".$use."\">".$use."</option>";
			}?>
		</select><br />
		<label for="class">DHCP Class: </label><select name="class">
			<option></option>
			<?foreach($classes as $class) {
				echo "<option value=\"".$class->get_class()."\">".$class->get_class()."</option>";
			}?>
		</select><br />
		
		<label for="commnet">Comment: </label><input type="text" name="comment" class="input_form_input" /><br />
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Create" class="input_form_submit"/>
	</form>
</div>