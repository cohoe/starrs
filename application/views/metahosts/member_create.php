<title>Testing</title>
<div class="item_container">
	<form method="POST" class="input_form">
		<label for="address">Address: </label><select name="address">
			<option></option>
			<? foreach ($addrs as $addr) {
					echo "<option value=\"".$addr->get_address()."\">".$addr->get_address()."</option>";
			} ?>
		</select><br/>
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Create" class="input_form_submit"/>
	</form>
</div>