<div class="item_container">
	<form method="POST" class="input_form">
		<label for="systemName">System Name: </label><input type="text" name="systemName" value="<?echo $system->get_system_name()?>" class="input_form_input" /><br />
		<label for="type">Type: </label><select name="type" class="input_form_input">
		<?
			foreach ($systemTypes as $type) {
				if($type == $system->get_type()) {
					echo '<option value="'.$type.'" selected>'.$type.'</option>';
				}
				else {
					echo '<option value="'.$type.'">'.$type.'</option>';
				}
			}
		?>
		</select><br />
		<label for="osName">Operating System: </label><select name="osName" class="input_form_input">
		<?
			foreach ($operatingSystems as $os) {
				if($os == $system->get_os_name()) {
					echo '<option value="'.$os.'" selected>'.$os.'</option>';
				}
				else {
					echo '<option value="'.$os.'">'.$os.'</option>';
				}
			}
		?>
		</select><br />
		<label for="comment">Comment: </label><input type="text" name="comment" value="<?echo $system->get_comment();?>" class="input_form_input" /><br />
		
		<? if(isset($admin)) {?>
			<label for="owner">Owner: </label><input type="text" name="owner" value="<?echo $system->get_owner();?>" class="input_form_input" /><br />
		<?} else {?>
			<input type="hidden" name="owner" value="<?echo $system->get_owner();?>" class="input_form_input" /><br />
		<?}?>
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Save" class="input_form_submit" class="input_form_input" />
	</form>

</div>