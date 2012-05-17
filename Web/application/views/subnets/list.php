<div class="item_container">
	<ul>
		<?foreach ($sNets as $sNet) {
			echo "<li><a href=\"/resources/subnets/view/".rawurlencode($sNet->get_subnet())."\">".htmlentities($sNet->get_subnet())."</a></li>";
		}?>
	</ul>
</div>
