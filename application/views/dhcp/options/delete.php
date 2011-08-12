<div class="item_container">
    <table class="tab_table">
        <tr><th>Option</th><th>Value</th><th>Delete</th></tr>
        <? foreach ($options as $option) {
            echo '<tr><td class="tab_table_left">'.htmlentities($option->get_option()).'</td><td class="tab_table_right">'.htmlentities($option->get_value()).'</td><td><a href="/dhcp/options/delete/'.$mode."/".rawurlencode($target)."/".rawurlencode($option->get_option())."/".rawurlencode($option->get_value()).'">X</a></td></tr>';
        } ?>
    </table>
</div>