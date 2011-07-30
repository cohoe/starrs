// Defining a function that will bind all the necessary functions to a txt
// field (as a jQuery object) that will check if a hostname is in use
// For this to work correctly, there must be a field with the ID 'zone'
// somewhere on the page (janky but it works).
(function($){
	$.fn.extend({
		hostnameInUse: function() {
			// @todo: There should be an error thrown here if the 
			// object we're binding this to isn't a text field

 			// When the field is tabbed out of or un clicked,
			return this.bind("blur", function() {
				// Grab the hostname and the zone
				var hostname = $(this).val();
				var zone = $("#zone").val();

				if(hostname == "" || zone == "") { 
					hostnameSpan = $("#hostnameSpan");
					if(hostnameSpan.lengh) {
						hostnameSpan.remove();
					}

					hostnameSpan = $("<span>");
					hostnameSpan.attr("id", "hostnameSpan");
					hostnameSpan.addClass("hostnameInUse");
					hostnameSpan.html("You must specify a hostname!");
					hostnameSpan.insertAfter("#hostname");
					return; 
				}
				
				// Now we verify it with a ajax call
				$.post(
					'/ajaxCalls/hostnameInUse',
					{ "hostname": hostname,
					  "zone": zone },
					function(data) {
						// If the hostname span already exists, we'll use it instead
						var hostnameSpan = $("#hostnameSpan");						
						
						if(hostnameSpan.length) {
							hostnameSpan.remove();
						}						

						hostnameSpan = $("<span>");							
						hostnameSpan.attr("id", "hostnameSpan");
						
						// Parse the data into a usable object
						var result = jQuery.parseJSON(data);
						
						// If we have an error, output it
						if(result.error != null) {
							hostnameSpan.addClass("hostnameInUse");
							hostnameSpan.html("AJAX error: " + result.error);
							hostname.insertAfter('#hostname');
							return;
						}
						
						// We should have info about if the hostname is in use
						if(result.inUse) {
							hostnameSpan.addClass("hostnameInUse");
							hostnameSpan.html("Hostname in Use!");
						} else {
							hostnameSpan.addClass("hostnameAvailable");
							hostnameSpan.html("Hostname Available!");
						}
						hostnameSpan.insertAfter("#hostname");
					}
				)
			});
		}
	});
})(jQuery);
	
// When the document is done loading, bind the function
$(document).ready(function() {
	$("#hostname").hostnameInUse();
});
