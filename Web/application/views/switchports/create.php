<div class="item_container">
    <form method="POST" class="input_form">
		<label for="portname">Port Name: </label><input type="text" name="portname" class="input_form_input" /><br />
        <div style="float: right; width: 100%; text-align: center; font-weight: bold;">-OR-</div>
        <label for="prefix">Prefix: </label><input type="text" name="prefix" class="input_form_input" /><br />
        <label for="first_num">First Port #: </label><input type="text" name="first_num" class="input_form_input" /><br />
        <label for="last_num">Last Port #: </label><input type="text" name="last_num" class="input_form_input" /><br />
        <br />
        <label for="system_name">System Name: </label><input type="text" name="system_name" value="<?echo $sys->get_system_name();?>" class="input_form_input" readonly /><br />
        <label for="type">Type: </label>
		<select name="type" class="input_form_input">
			<? foreach ($types as $type) {
				echo "<option value=\"".$type."\">".$type."</option>";
			} ?>
		</select><br />
        <label for="description">Description: </label><input type="text" name="description" class="input_form_input" /><br />

		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Create" class="input_form_submit"/>
	</form>
</div>