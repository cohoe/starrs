<div class="item_container">
	<form method="POST" class="input_form">
		<label for="keyname">Name: </label><input type="text" name="keyname" value="<?echo $dnsKey->get_keyname()?>" class="input_form_input" /><br />
		<label for="key">Key: </label><input type="text" name="key" value="<?echo $dnsKey->get_key()?>" class="input_form_input" /><br />
		<label for="comment">Comment: </label><input type="text" name="comment" value="<?echo $dnsKey->get_comment()?>" class="input_form_input" /><br /><br />
		<? if(isset($admin)) {?>
			<label for="owner">Owner: </label><input type="text" name="owner" value="<?echo $dnsKey->get_owner();?>" class="input_form_input" /><br />
		<?} else {?>
			<input type="hidden" name="owner" value="<?echo $dnsKey->get_owner();?>" class="input_form_input" /><br />
		<?}?>
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Save" class="input_form_submit"/>
	</form>
</div>