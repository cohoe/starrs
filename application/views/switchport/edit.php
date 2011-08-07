<div class="item_information_area">
    <form method="POST" class="input_form">
        <label for="system_name">System Name: </label><input type="text" name="system_name" value="<?echo $sPort->get_system_name();?>" class="input_form_input" readonly /><br />
        <label for="port_name">Port Name: </label><input type="text" name="port_name" value="<?echo $sPort->get_port_name();?>" class="input_form_input" /><br />
        <label for="type">Type: </label>
		<select name="type" class="input_form_input">
			<? foreach ($types as $type) {
                if($sPort->get_type() == $type) {
                    echo "<option value=\"".$type."\" selected>".$type."</option>";
                }
                else {
				    echo "<option value=\"".$type."\">".$type."</option>";
                }
			} ?>
		</select><br />
        <label for="description">Description: </label><input type="text" name="description" value="<?echo $sPort->get_description();?>" class="input_form_input" /><br />
        <label for="enable">Enable?: </label>
		<input type="radio" name="enable" value="t" class="input_form_radio" <?echo ($sys->get_switchview_enable()=='t')?"checked":""?> />Yes
		<input type="radio" name="enable" value="f" class="input_form_radio" <?echo ($sys->get_switchview_enable()=='f')?"checked":""?> />No
        <br />
        <label for="submit">&nbsp;</label><input type="submit" name="submit" value="Create" class="input_form_submit"/>
	</form>
</div>