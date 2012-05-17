<div class="item_container">
	<div class="prompt">
		<form method="POST" class="prompt_form">
			<?echo htmlentities($message);?>
			<input type="hidden" name="url" value="<?echo $rejectUrl;?>" /><br />
			<input type="submit" name="yes" value="Yes"class="prompt_form_submit" />
			<input type="submit" name="no" value="No" class="prompt_form_submit" />
		</form>
	</div>
</div>
