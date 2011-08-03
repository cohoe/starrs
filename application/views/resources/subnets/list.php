<div class="item_container">
	<ul>
		<?foreach ($sNets as $sNet) {
			echo "<li><a href=\"/resources/subnets/view/".urlencode($sNet->get_subnet())."\">".$sNet->get_subnet()."</a></li>";
		}?>
	</ul>
</div>
