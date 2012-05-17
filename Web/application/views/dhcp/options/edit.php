<div class="item_container">
    <table class="tab_table">
        <tr><th>Option</th><th>Value</th><th>Edit</th></tr>
        <? foreach ($options as $option) {
            echo '<tr><td class="tab_table_left">'.htmlentities($option->get_option()).'</td><td class="tab_table_right">'.htmlentities($option->get_value()).'</td><td><a href="/dhcp/options/edit/'.$mode."/".rawurlencode($target)."/".rawurlencode($option->get_option())."/".rawurlencode($option->get_value()).'">E</a></td></tr>';
        } ?>
    </table>
</div>