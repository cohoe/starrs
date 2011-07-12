<div class="item_container">
	<form method="POST" class="prompt_form">
		<?echo $message;?>
		<input type="hidden" name="url" value="<?echo $rejectUrl;?>" /><br />
		<input type="submit" name="yes" value="Yes"class="prompt" />
		<input type="submit" name="no" value="No" class="prompt" />
	</form>

</div>
