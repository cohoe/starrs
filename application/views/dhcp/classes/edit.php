<div class="item_container">
	<form method="POST" class="input_form">
		<label for="class">Class: </label><input type="text" name="class" value="<?echo htmlentities($class->get_class());?>" class="input_form_input" /><br />
		<label for="comment">Comment: </label><input type="text" name="comment" value="<?echo htmlentities($class->get_comment());?>" class="input_form_input" /><br />
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Save" class="input_form_submit"/>
	</form>
</div>