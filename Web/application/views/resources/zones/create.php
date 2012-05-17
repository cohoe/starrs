<div class="item_container">
	<form method="POST" class="input_form">
		<label for="zone">Zone: </label><input type="text" name="zone" class="input_form_input" /><br />
		<label for="keyname">DNS Key: </label><select name="keyname">
			<option></option>
			<?foreach($dnsKeys as $key) {
				echo "<option value=\"".$key->get_keyname()."\">".$key->get_keyname()."</option>";
			}?>
		</select><br />
		
		<label for="forward">Forward?: </label>
			<input type="radio" name="forward" value="t" class="input_form_radio" checked />Yes
			<input type="radio" name="forward" value="f" class="input_form_radio" />No
		<br />
		<label for="shared">Shared?: </label>
			<input type="radio" name="shared" value="t" class="input_form_radio" />Yes
			<input type="radio" name="shared" value="f" class="input_form_radio" checked />No
		<br />
		<label for="comment">Comment: </label><input type="text" name="comment" class="input_form_input" /><br /><br />
		<? if(isset($admin)) {?>
			<label for="owner">Owner: </label><input type="text" name="owner" value="<?echo $user;?>" class="input_form_input" /><br />
		<?} else {?>
			<input type="hidden" name="owner" value="<?echo $user;?>" class="input_form_input" /><br />
		<?}?>
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Create" class="input_form_submit"/>
	</form>
</div>