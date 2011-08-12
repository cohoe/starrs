<!-- THIS FILE HAS BEEN DEPRECATED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
<div class="item_container">
	<? if($address->get_address_record()){?>
		<div class="item_information_area_container">
		Address Records (A, AAAA)
			<table class="dns_information_area_table">
				<tr><th>DNS Name</th><th>Type</th><th>Delete</th></tr>
				<tr>
					<td><?echo $address->get_address_record()->get_hostname().".".$address->get_address_record()->get_zone();?></td>
					<td><?echo $address->get_address_record()->get_type();?></td>
					<td><a href="<?echo "/dns/delete/".$address->get_address()."/".$address->get_address_record()->get_type()."/".$address->get_address_record()->get_zone()."/".$address->get_address_record()->get_hostname();?>">X</a></td>
				</tr>
			</table>
		</div>
	<?} if($address->get_pointer_records()) {?>
		<div class="item_information_area_container">
		Pointer Records (CNAME, SRV)
		<table class="dns_information_area_table">
			<tr><th>Alias</th><th>Target</th><th>Extra</th><th>Type</th><th>Delete</th></tr>
			<? foreach ($address->get_pointer_records() as $pointer) { ?>
				<tr>
					<td><?echo $pointer->get_alias();?></td>
					<td><?echo $pointer->get_hostname().".".$pointer->get_zone();?></td>
					<td><?echo $pointer->get_extra();?></td>
					<td><?echo $pointer->get_type();?></td>
					<td><a href="<?echo "/dns/delete/".$pointer->get_address()."/".$pointer->get_type()."/".$pointer->get_zone()."/".$pointer->get_hostname()."/".$pointer->get_alias();?>">X</a></td>
				</tr>
			<?}?>
		</table>
		</div>
	<?} if($address->get_text_records()) {?>
		<div class="item_information_area_container">
		Text Records (TXT, SPF)
		<table class="dns_information_area_table">
			<tr><th>Text</th><th>Delete</th></tr>
			<? foreach ($address->get_text_records() as $text) { ?>
			<tr>
				<td><?echo $text->get_text();?></td>
				<td><a href="<?echo "/dns/delete/".$text->get_address()."/".$text->get_type()."/".$text->get_zone()."/".$text->get_hostname();?>">X</a></td>
			</tr>
			<?}?>
		</table>
		</div>
	<?} if($address->get_ns_records()) {?>
		<div class="item_information_area_container">
		Nameserver Records (NS)
		<table class="dns_information_area_table">
			<tr><th>Zone</th><th>Primary</th><th>Delete</th></tr>
			<? foreach ($address->get_ns_records() as $ns) { ?>
			<tr>
				<td><?echo $ns->get_zone();?></td>
				<td><?echo $ns->get_isprimary();?></td>
				<td><a href="<?echo "/dns/delete/".$address->get_address()."/".$ns->get_type()."/".$ns->get_zone()."/".$ns->get_hostname();?>">X</a></td>
			</tr>
			<?}?>
		</table>
		</div>
	<?} if($address->get_mx_records()) {?>
		<div class="item_information_area_container">
		Mailserver Records (MX)
		<table class="dns_information_area_table">
			<tr><th>Preference</th><th>Delete</th></tr>
			<? foreach ($address->get_mx_records() as $mx) { ?>
			<tr>
				<td><?echo $mx->get_preference();?></td>
				<td><a href="<?echo "/dns/delete/".$mx->get_address()."/".$mx->get_type()."/".$mx->get_zone()."/".$mx->get_hostname();?>">X</a></td>
			</tr>
			<?}?>
		</table>
		</div>
	<?}
    if(!$address->get_address_record() && !$address->get_pointer_records() && !$address->get_text_records() && !$address->get_ns_records() && !$address->get_mx_records()) {
        ?>
        <div class="item_information_area_container">
		No DNS records found for this IP address
        </div>
        <?}?>
	</div>
</div>
-->