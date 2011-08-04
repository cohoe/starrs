<div class="item_container">
    <table>
        <tr><th>Option</th><th>Value</th></tr>
        <? foreach ($options as $option) {
            echo '<tr><td style="text-align:right;">'.$option->get_option().'</td><td style="text-align:left;">'.$option->get_value().'</tr>';
        } ?>
    </table>
</div>