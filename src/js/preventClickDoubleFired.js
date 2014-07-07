/**
 * Prevent from click event being double fired in Android Web View
 */
document.addEventListener('click', function(eventObj){
	var curTime = (new Date()).getTime();
	if(window.lastClickEventTime != undefined 
		&& (curTime - window.lastClickEventTime) <= 600) {
		eventObj.stopPropagation();
	}
	
	window.lastClickEventTime = (new Date()).getTime();
}, true);
