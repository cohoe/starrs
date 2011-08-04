<div class="item_container">
    <table style="border: 1px solid black">
        <tr><th>Option</th><th>Value</th></tr>
        <? foreach ($options as $option) {
            echo '<tr><td style="text-align:right; margin-right: .5em;">'.$option->get_option().'</td><td style="text-align:left; margin-left: .5em;">'.$option->get_value().'</tr>';
        } ?>
    </table>
</div>