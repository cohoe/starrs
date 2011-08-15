<div class="item_container">
	<form method="POST" class="input_form">
		<label for="zone">Zone: </label><input type="text" name="zone" value="<?echo $dnsZone->get_zone()?>" class="input_form_input" /><br />
		<label for="keyname">DNS Key: </label><select name="keyname">
			<option></option>
			<?foreach($dnsKeys as $key) {
				if($key->get_keyname() == $dnsZone->get_keyname()) {
					echo "<option value=\"".$key->get_keyname()."\" selected>".$key->get_keyname()."</option>";
				}
				else {
					echo "<option value=\"".$key->get_keyname()."\">".$key->get_keyname()."</option>";
				}
			}?>
		</select><br />
		
		<label for="forward">Forward?: </label>
			<input type="radio" name="forward" value="t" class="input_form_radio" <?echo ($dnsZone->get_forward()=='t')?"checked":"";?> />Yes
			<input type="radio" name="forward" value="f" class="input_form_radio" <?echo ($dnsZone->get_forward()=='f')?"checked":"";?> />No
		<br />
		<label for="shared">Shared?: </label>
			<input type="radio" name="shared" value="t" class="input_form_radio" <?echo ($dnsZone->get_shared()=='t')?"checked":"";?> />Yes
			<input type="radio" name="shared" value="f" class="input_form_radio" <?echo ($dnsZone->get_shared()=='f')?"checked":"";?> />No
		<br />
		<label for="comment">Comment: </label><input type="text" name="comment" value="<?echo $dnsZone->get_comment()?>" class="input_form_input" /><br /><br />
		<? if(isset($admin)) {?>
			<label for="owner">Owner: </label><input type="text" name="owner" value="<?echo $dnsZone->get_owner();?>" class="input_form_input" /><br />
		<?} else {?>
			<input type="hidden" name="owner" value="<?echo $dnsZone->get_owner();?>" class="input_form_input" /><br />
		<?}?>
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Save" class="input_form_submit"/>
	</form>
</div>