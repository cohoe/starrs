<div class="item_container">
    <table class="tab_table">
        <tr><th>Option</th><th>Value</th></tr>
        <? foreach ($options as $option) {
            echo '<tr><td class="tab_table_left">'.htmlentities($option->get_option()).'</td><td class="tab_table_right">'.htmlentities($option->get_value()).'</td></tr>';
        } ?>
    </table>
</div>