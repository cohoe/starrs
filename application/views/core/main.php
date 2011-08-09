<!DOCTYPE html>
<html>

<head>
	<title>IMPULSE: <?echo $title;?></title>
	<link href="/css/sphere/full/main.css" rel="stylesheet" type="text/css" />
	<link href="/css/sphere/full/impulse.css" rel="stylesheet" type="text/css" />
	<link href="/css/sphere/full/form.css" rel="stylesheet" type="text/css" />
	<link href="/css/sphere/full/navbar.css" rel="stylesheet" type="text/css" />
	<link href="/css/sphere/full/interfaces.css" rel="stylesheet" type="text/css" />
	<link href="/css/sphere/full/addresses.css" rel="stylesheet" type="text/css" />
	<link href="/css/sphere/full/systems.css" rel="stylesheet" type="text/css" />
    <link href="/css/sphere/full/tabledata.css" rel="stylesheet" type="text/css" />
	<style>#helpDiv { display:none; background-color:green;}</style><!-- @todo: not sure if this should be it's own css file -->
	<!-- Also ^ needs to have the padding the same color as the background -->
	
	<script type="text/javascript" src='/js/jquery-1.6.2.js'></script>
	<script type="text/javascript" src='/js/help.js'></script>
</head>

<body>
	<div class="content">
		<?echo $header;?>
		<?echo $sidebar;?>
		<div class="information">
			<?echo $navbar;?>
			<?if(isset($help)) { echo $help; }?>
			<div id="dataDiv">
			<?echo $data;?>
			</div>
		</div>
		<div style="width: 100%; height: 1.2em; border: 1px solid black; text-align: center; float: left;">Created by Grant Cohoe</div>
	</div>
	
</body>

</html>
