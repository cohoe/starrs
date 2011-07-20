<div class="item_container">
	<form method="POST" class="input_form">
		<label for="type">Record Type: </label><input type="text" name="type" value="<?echo $type;?>" class="input_form_input" readonly />
		<label for="address">Address: </label><input type="text" name="address" value="<?echo $addr->get_address();?>" class="input_form_input" readonly />
		<? switch($type) {
			case "NS":?>
				<label for="hostname">Hostname: </label><input type="text" name="hostname" class="input_form_input" value="<?echo $addr->get_address_record()->get_hostname();?>" readonly /><br>
				<label for="zone">Domain: </label>
				<select name="zone" class="input_form_input" readonly>
					<? foreach ($zones as $zone) {
						if($zone = $addr->get_address_record()->get_zone()) {
							echo "<option value=\"$zone\" selected=\"selected\">$zone</option>";
						}
						else {
							echo "<option value=\"$zone\">$zone</option>";
						}
					} ?>
				</select><br />
				<label for="isprimary">Primary?: </label>
				<input type="radio" name="isprimary" value="t" class="input_form_radio" checked />Yes
				<input type="radio" name="isprimary" value="f" class="input_form_radio" />No
				<?break;
			case "MX":
				break;
			case "CNAME":
				break;
			case "SRV":
				break;
			case "TXT":
				break;
			case "SPF":
				break;
			default:?>
				<label for="hostname">Hostname: </label><input type="text" name="hostname" class="input_form_input" /><br>
				<label for="zone">Domain: </label>
				<select name="zone" class="input_form_input">
					<? foreach ($zones as $zone) {
						echo "<option value=\"$zone\">$zone</option>";
					} ?>
				</select>
				<?break;
		}
		?>
			<label for="ttl">TTL: </label><input type="ttl" name="ttl" class="input_form_input" />
		<?
		
		// Owner input
		if(isset($admin)) {?>
			<label for="owner">Owner: </label><input type="text" name="owner" value="<?echo $user;?>" class="input_form_input" />
		<?}
		else {?>
			<input type="text" name="owner" value="<?echo $user;?>" class="input_form_input" hidden="true" />
		<?}
		
		// Submit button
		?>
		<label for="submit">&nbsp;</label><input type="submit" name="recordSubmit" value="Create" class="input_form_submit"/>
	</form>
</div>
