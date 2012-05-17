<div class="item_container">
	<form method="POST" class="input_form">
		<label for="name">Name: </label><input type="text" name="name" value="<?echo htmlentities($ipRange->get_name());?>" class="input_form_input" /><br />
		<label for="first_ip">First IP: </label><input type="text" name="first_ip" value="<?echo htmlentities($ipRange->get_first_ip());?>" class="input_form_input" /><br />
		<label for="last_ip">Last IP: </label><input type="text" name="last_ip" value="<?echo htmlentities($ipRange->get_last_ip());?>" class="input_form_input" /><br />
		<label for="subnet">Subnet: </label><select name="subnet">
			<?foreach($sNets as $sNet) {
				if($sNet->get_subnet() == $ipRange->get_subnet()) {
					echo "<option value=\"".$sNet->get_subnet()."\" selected>".$sNet->get_subnet()."</option>";
				}
				else {
					echo "<option value=\"".$sNet->get_subnet()."\">".$sNet->get_subnet()."</option>";
				}
			}?>
		</select><br />
		<label for="use">Use Code: </label><select name="use">
			<?foreach($uses as $use) {
				if($ipRange->get_use() == $use) {
					echo "<option value=\"".$use."\" selected>".$use."</option>";
				}
				else {
					echo "<option value=\"".$use."\">".$use."</option>";
				}
			}?>
		</select><br />
		<label for="class">DHCP Class: </label><select name="class">
			<option></option>
			<?foreach($classes as $class) {
				if($ipRange->get_class() == $class->get_class()) {
					echo "<option value=\"".$class->get_class()."\" selected>".$class->get_class()."</option>";
				}
				else {
					echo "<option value=\"".$class->get_class()."\">".$class->get_class()."</option>";
				}
			}?>
		</select><br />
		
		<label for="commnet">Comment: </label><input type="text" name="comment" value="<?echo htmlentities($ipRange->get_comment());?>" class="input_form_input" /><br />
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Save" class="input_form_submit"/>
	</form>
</div>