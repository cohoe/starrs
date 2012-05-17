<div class="item_container">
	<form method="POST" class="input_form">
	    <label for="ro_community">SNMP RO: </label><input type="text" name="ro_community" class="input_form_input" /><br />
        <label for="rw_community">SNMP RW: </label><input type="text" name="rw_community" class="input_form_input" /><br />
		<label for="enable">Enable?: </label>
		<input type="radio" name="enable" value="t" class="input_form_radio" checked />Yes
		<input type="radio" name="enable" value="f" class="input_form_radio" />No
        <br />
		<label for="submit">&nbsp;</label><input type="submit" name="submit" value="Create" class="input_form_submit"/>
	</form>
</div>