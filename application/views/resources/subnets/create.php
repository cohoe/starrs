<div class="item_container">
	<form method="POST" class="input_form">
		<label for="subnet">CIDR Subnet: </label><input type="text" name="subnet" class="input_form_input" /><br />
		<label for="name">Name: </label><input type="text" name="name" class="input_form_input" /><br />
		<label for="comment">Comment: </label><input type="text" name="comment" class="input_form_input" /><br /><br />
		<label for="autogen">Autogenerate?: </label>
			<input type="radio" name="autogen" value="t" class="input_form_radio" checked />Yes
			<input type="radio" name="autogen" value="f" class="input_form_radio" />No
		<br />
		<label for="zone">DNS Zone: </label><select name="zone">
			<option></option>
			<?foreach($dnsZones as $zone) {
				echo "<option value=\"".$zone->get_zone()."\">".$zone->get_zone()."</option>";
			}?>
		</select><br />
		
		<? if(isset($admin)) {?>
			<label for="dhcp">Enable DHCP?: </label>
				<input type="radio" name="dhcp" value="t" class="input_form_radio" checked />Yes
				<input type="radio" name="dhcp" value="f" class="input_form_radio" />No
			<br />
			<label for="owner">Owner: </label><input type="text" name="owner" value="<?echo $user;?>" class="input_form_input" /><br />
		<?} else {?>
			<input type="hidden" name="owner" value="<?echo $user;?>" class="input_form_input" /><br />
			<input type="hidden" name="dhcp" value="f" />
		<?}?>
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Create" class="input_form_submit"/>
	</form>
</div>