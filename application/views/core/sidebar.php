<div class="sidebar">
	<ul>
	<? 
		$headings = $sidebar->get_nav_headings();
		foreach($headings as $navItem) {
			echo '<li><a href="'.$navItem->get_link().'">'.$navItem->get_title().'</a></li>';
			if($navItem->get_views()) {
			
				echo '<ul>';
				foreach(array_keys($navItem->get_views()) as $view) {
					if(is_array($navItem->get_view_link($view))) {
						$options = $navItem->get_view_link($view);
						echo '<li><a href="'.$options['Base'].'">'.$view.'</a></li>';
						echo '<ul>';
						foreach(array_keys($options) as $option) {
							if($option != 'Base') {
								echo '<li><a href="'.$options[$option].'">'.$option.'</a></li>';
							}
						}
						echo '</ul>';
					}
					else {
						echo '<li><a href="'.$navItem->get_view_link($view).'">'.$view.'</a></li>';
					}
				}
				echo '</ul>';
			}
		}
	?>
	<ul>
</div>