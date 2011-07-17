<title>Testing</title>
<div class="item_container">
	<form method="POST" class="create_form">
		<label for="systemName">System Name: </label><input type="text" name="systemName" value="<?echo $system->get_system_name()?>"/><br />
		<label for="type">Type: </label><select name="type">
		<?
			foreach ($systemTypes as $type) {
				if($type == $system->get_type()) {
					echo "<option value=\"$type\" selected=\"selected\">$type</option>";
				}
				else {
					echo "<option value=\"$type\">$type</option>";
				}
			}
		?>
		</select><br />
		<label for="osName">Operating System: </label><select name="osName">
		<?
			foreach ($operatingSystems as $os) {
				if($os == $system->get_os_name()) {
					echo "<option value=\"$os\" selected=\"selected\">$os</option>";
				}
				else {
					echo "<option value=\"$os\">$os</option>";
				}
			}
		?>
		</select><br />
		<label for="comment">Comment: </label><input type="text" name="comment" value="<?echo $system->get_comment();?>"/><br />
		
		<? if(isset($admin)) {?>
			<label for="owner">Owner: </label><input type="text" name="owner" value="<?echo $system->get_owner();?>" /><br />
		<?} else {?>
			<input type="hidden" name="owner" value="<?echo $user;?>" /><br />
		<?}?>
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Save" class="submit"/>
	</form>

</div>
