<div class="item_container">
	<form method="POST" class="input_form">
		<label for="type">Record Type: </label><input type="text" name="type" value="<?echo $type;?>" class="input_form_input" disabled />
		<? switch($type) {
			case "NS":?>
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
				<label for="address">Address: </label><input type="text" name="address" value="<?echo $addr->get_address();?>" class="input_form_input" disabled />
				<label for="hostname">Hostname: </label><input type="text" name="hostname" class="input_form_input" /><br>
				<label for="zone">Domain: </label>
				<select name="zone" class="input_form_input">
					<? foreach ($zones as $zone) {
						echo "<option value=\"$zone[get_zones]\">$zone[get_zones]</option>";
					} ?>
				</select>
				<label for="ttl">TTL: </label><input type="ttl" name="ttl" class="input_form_input" />
				<?break;
		}
		if(isset($admin)) {?>
			<label for="owner">Owner: </label><input type="text" name="owner" value="<?echo $user;?>" class="input_form_input" />
		<?}
		else {?>
			<input type="text" name="owner" value="<?echo $user;?>" class="input_form_input" hidden="true" />
		<?}?>
		<label for="submit">&nbsp;</label><input type="submit" name="recordSubmit" value="Create" class="input_form_submit"/>
	</form>
</div>
