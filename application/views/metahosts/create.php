<div class="item_container">
	<form method="POST" class="input_form">
		<label for="name">Name: </label><input type="text" name="name" class="input_form_input" /><br />
		<? if(isset($admin)) {?>
			<label for="owner">Owner: </label><input type="text" name="owner" value="<?echo $user;?>" class="input_form_input" /><br />
		<?} else {?>
		<input type="hidden" name="owner" value="<?echo $user;?>" class="input_form_input" />
		<?}?>
		<label for="comment">Comment: </label><input type="text" name="comment" class="input_form_input" /><br />
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Create" class="input_form_submit" class="input_form_input" />
	</form>
</div>