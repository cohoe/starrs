<div class="item_container">
    <table style="border: 1px solid black; margin-left: auto; margin-right: auto;">
        <tr style="border-bottom: 1px solid black;"><th>Option</th><th>Value</th></tr>
        <? foreach ($options as $option) {
            echo '<tr><td style="text-align:right; padding-right: .5em;">'.$option->get_option().'</td><td style="text-align:left; padding-left: .5em;">'.$option->get_value().'</tr>';
        } ?>
    </table>
</div>