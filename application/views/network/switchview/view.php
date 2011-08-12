<div class="item_information_area">
    <table class="item_information_area_table">
        <tr><td><em>Enabled?:</em></td><td><?echo ($settings['enable']=='t')?"True":"False";?></td></tr>
        <tr><td><em>SNMP RO Community:</em></td><td><?echo htmlentities($settings['snmp_ro_community']);?></td></tr>
        <tr><td><em>SNMP RW Community:</em></td><td><?echo htmlentities($settings['snmp_rw_community']);?></td></tr>
    </table>
</div>