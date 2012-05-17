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
	<link href="/css/sphere/full/sidebar.css" rel="stylesheet"  type="text/css" />
	
	<script type="text/javascript" src='/js/jquery-1.6.2.js'></script>
	<script type="text/javascript" src='/js/help.js'></script>
	<script src="/js/jquery.cookie.js" type="text/javascript"></script>
	<script src="/js/jquery.treeview.js" type="text/javascript"></script>
	<script type="text/javascript">
	$(function() {
		$("#tree").treeview({
			collapsed: true,
			//animated: "fast",
			control:"#sidetreecontrol",
			prerendered: true,
			//persist: "location"
			persist: "cookie"
		});
	})	
	</script>
</head>

<body>
	<div class="content">
		<?echo $header;?>
		<?echo $sidebar;?>
		<div class="information">
			<?echo $navbar;?>
			<?if(isset($help)) { echo '<div id="helpDiv">'.$help.'</div>'; }?>
			<div id="dataDiv">
			<?echo $data;?>
			</div>
		</div>
		<!--<div class="footer">Created 2011 by Grant Cohoe &amp; the IMPULSE Development Team</div>-->
	</div>
	
</body>

</html>
