/**
 * This file declares functionality for displaying and hiding help inline
 */

function toggleHelp() {
	// Grab the div that contains the help
	var helpDiv =  document.getElementById('helpDiv');
	
	// If it's not visible, we've got a contingency
	if(helpDiv == null) {
		// Create a new helpDiv
		helpDiv = document.createElement("div");
		helpDiv.id = "helpDiv";
		helpDiv.className = "item_container";
		
		// Insert it before the important stuff
		dataDiv = document.getElementById("dataDiv");
		dataDiv.insertBefore(helpDiv, dataDiv);
	}
	
	// Now animate it open
	helpDiv.slideToggle("slow")
}