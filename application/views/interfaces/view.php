<div class="item_container">
    <table class="item_information_area_table">
        <tr><td><em>Name:</em></td><td><?echo $interface->get_interface_name();?></td></tr>
        <tr><td><em>MAC:</em></td><td><?echo $interface->get_mac();?></td></tr>
        <tr><td><em>Comment:</em></td><td><?echo $interface->get_comment();?></td></tr>
    </table>
    <div class="infobar">
        <span class="infobar_text">Created on <?echo $interface->get_date_created();?> - Modified by <?echo $interface->get_last_modifier();?> on <?echo $interface->get_date_modified();?></span>
    </div>
</div>