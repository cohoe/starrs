<title>Testing</title>
<div class="item_container">
	<form method="POST" class="create_form">
		<label for="address">Address: </label><select name="address">
			<? foreach ($addresses as $intAddr) {
				if($intAddr->get_address() == $address) {
					echo "<option value=\"".$intAddr->get_address()."\" selected=\"true\" >".$intAddr->get_address()."</option>";
				}
				else {
					echo "<option value=\"".$intAddr->get_address()."\">".$intAddr->get_address()."</option>";
				}
			} ?>
		</select></br>
		<input type="submit" name="submit" value="Delete" class="submit"/>
	</form>
</div>