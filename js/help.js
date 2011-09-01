/**
 * This file declares functionality for displaying and hiding help inline
 */

function toggleHelp() {
	// If it doesn't exist, we're not going to show it, but we'll follow the link
	helpDiv = document.getElementById("helpDiv");

	if(helpDiv == null || helpDiv == undefined) {
		return true;
	}
	
	// Now animate it open
	$("#helpDiv").slideToggle("slow");
	return false;
}
