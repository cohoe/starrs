<div class="item_container">
	<form method="POST" class="input_form">
		<label for="type">Record Type: </label>
		<select name="type" class="input_form_input">
			<? foreach ($types as $type) {
				echo '<option value="'.$type.'">'.$type.'</option>';
			} ?>
		</select>
		<br />
		<label for="submit">&nbsp;</label><input type="submit" name="typeSubmit" value="Continue" class="input_form_submit"/>
	</form>
</div>
