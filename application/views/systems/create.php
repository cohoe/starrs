<div class="item_container">

	<form method="POST" class="create_form">
		<label for="systemName">System Name: </label><input type="text" name="systemName" /><br />
		<label for="type">Type: </label><select name="type">
		<?
			foreach ($systemTypes as $type) {
				echo "<option value=\"$type\">$type</option>";
			}
		?>
		</select><br />
		<label for="osName">Operating System: </label><select name="osName">
		<?
			foreach ($operatingSystems as $os) {
				echo "<option value=\"$os\">$os</option>";
			}
		?>
		</select><br />
		<label for="comment">Comment: </label><input type="text" name="comment" /><br />
		
		<? if(isset($admin)) {?>
			<label for="owner">Owner: </label><input type="text" name="owner" value="<?echo $user;?>" /><br />
		<?}?>
		
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Create System" class="submit"/>
	</form>

</div>
