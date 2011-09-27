<!--Load the AJAX API-->
<script type="text/javascript" src="https://www.google.com/jsapi"></script>
<script type="text/javascript">

	// Load the Visualization API and the piechart package.
	google.load('visualization', '1', {'packages':['corechart']});

	// Set a callback to run when the Google Visualization API is loaded.
	google.setOnLoadCallback(drawChart);

	// Callback that creates and populates a data table,
	// instantiates the pie chart, passes in the data and
	// draws it.
	function drawChart() {

		// Create our data table.
		var data = new google.visualization.DataTable();
		data.addColumn('string', 'Topping');
		data.addColumn('number', 'Slices');
		data.addRows([
			['In Use',<?="$data[inuse]";?>],
			['Free',<?="$data[free]";?>]
		]);

		// Instantiate and draw our chart, passing in some options.
		var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
		chart.draw(data, {width: 400, height: 240});
	}
</script>

<div class="item_container">
	<table>
		<tr><td>Subnet:</td><td><?=htmlentities($data['subnet'])?></td><tr>
		<tr><td>In Use:</td><td><?=htmlentities($data['inuse'])?></td><tr>
		<tr><td>Free:</td><td><?=htmlentities($data['free'])?></td><tr>
		<tr><td>Total:</td><td><?=htmlentities($data['total'])?></td><tr>
	</table>
</div>
<div class="item_container">
	<div id="chart_div"></div>
</div>
