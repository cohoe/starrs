<div class="item_container">
    <? foreach ($sPorts as $sPort) {?>
        <div style="border: 1px solid black; margin: 1px; width: 48px; height: 48px; float: left;"><?echo $sPort->get_port_name();?></div>
    <?} ?>
</div>