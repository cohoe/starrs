<?php
	$PAGE = 'serverStatus.php';
	
	if (isset($_GET['timeout']))
		$timeout=max($_GET['timeout'],1);
	else
		$timeout=1;
	function microtime_float(){
		list($usec, $sec) = explode(" ", microtime());
		return ((float)$usec + (float)$sec);
	}
	function sendImage($fileName){
		$file = fopen($fileName,'r');
		header('Content-type: image/png');
		fpassthru($file);
		fclose($file);
	}
	function sendFile($fileName){
		$file = fopen($fileName,'r');
		header('Content-type: text/plain; charset=us-ascii');
		fpassthru($file);
		fclose($file);
	}
	function printUsage(){
		?>
		<pre>Useage: <? echo $PAGE ?>?host=&lt;hostname&gt;&port=&lt;port&gt;[&verbose][&timeout=&lt;seconds&gt;][&download]
	
	Server:		Hostname or IP address
	Port:		Port to attempt connection to
	Verbose:	Enable detailed textual display
	Timeout:	Seconds for socket timeout
	Download:	Ignore other input and download source of script
		</pre>
		<?
	}
	function checkServer(){
		global $host, $port, $timeout, $image, $status, $handle, $errno, $errstr;
		$handle=@fsockopen($host, $port, $errno, $errstr, $timeout);
		if (!$handle){
			@fclose($handle);
			switch ($errno){
				case 0:
				case 8:
				case 113:
					$image = "error";
					$status= "DNS/Route Error";
					break;
				case 10060:
				case 111:
					$image = "down";
					$status= "Connection Refused";
					break;
				case 110:
					$image = "time";
					$status= "Socket Timeout";
					break;
				default:
					$image = "what";
					$status= "Unknown, please report status to obive.net to get added to script";
			}
		}else {
			//looks like we opened a socket! its probably up!
			@fclose($handle);
			$image = "up";
		}
		$image .= ".png";
	}
	if (isset($_GET['download'])){
		sendFile($PAGE);
		die();
	}
	
	$host = $_GET['host'];
	$port = $_GET['port'];
	if (!isset($_GET['verbose'])){
		if (!isset($_GET['host']) || !isset($_GET['port'])){ 
			printUsage();
		}else{
			checkServer();
			sendImage($image);
		}
	}else{
?><html>
	<head>
		<title>Server Status</title>
	</head>
	<body>
		<h1>Server Status:</h1>
		<h2>Input:</h2>
		<blockquote>
		  <p>
			<strong>Host: </strong><?php echo($host); ?><br/>
			<strong>Port: </strong><?php echo($port); ?><br/>
		  <strong>Timeout: </strong><?php echo($timeout . (( $timeout > 1 ) ? " seconds" : " second")); ?></p>
		</blockquote>
		<h2>Basic:</h2>
		<blockquote>
		  <p>
		<?php
				$ip = gethostbyname($host);
				$name=gethostbyaddr($ip);
		?>
			<strong>Resolved IP address: </strong><?php echo($ip); ?><br/>
			<strong>Reverse name lookup: </strong><?php echo($name); ?><br/>
			<strong>Service: </strong><?php echo(getservbyport($port,"tcp")); ?>  </p>
		</blockquote>
		<h2>Socket:</h2>
		<blockquote>
		  <p>
		<?php
				$time =microtime_float();
				checkServer($host, $port);
				$time=round ((microtime_float()-$time)*1000);
		?>
			<strong>Handle: </strong><?php echo($handle); ?><br/>
			<strong>Error Number: </strong><?php echo($errno); ?><br/>
			<strong>Error String: </strong><?php echo($errstr); ?><br/>
			<br/>
			<strong>Result: </strong><?php echo($status); ?><br/>
			<strong>Result Time: </strong><?php echo($time); ?> ms
		  </p>
		</blockquote>
		<h2>Image:</h2>
		<blockquote>
			<strong>FileName: </strong><?php echo($image); ?><br/>
			<strong>Image: </strong><img width="10" height="10" src="<?php echo($image); ?>">
		</blockquote>
		<strong><a href="<?php echo($PAGE); ?>?download">Script</a> by: </strong><a href="http://www.obive.net">Charlie Hayes</a>
		<?php printUsage(); ?>
	</body>
</html>
<?php
	}
?>