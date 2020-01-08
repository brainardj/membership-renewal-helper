<script type="text/javascript">
$(document).ready( function(){
console.log("CLICKPDX: Overriding A4J error handler.");
A4J.AJAX.replacePage = function(req){
    if(req){
    console.log("A4J AJAX error: ");
    console.log(req.getError());

    } else console.log("A4J AJAX error, but no req object passed.");
    
    return false;
};
A4J.AJAX.onError = function(req,status,message){
    alert("There was an A4J error.");
	console.log(req);
	// console.log(status);
	// console.log(message);
	// var domresponse = req.getResponseText();
	req.status = status;
	
	alert(req.getError());
	
	return false;


	// Default error handling text in A4J.AJAX.XmlHTTPRequest.prototype._onerror 
	// here for posterity
	/*
		if(status!=599 && req.getResponseText() && !req.options.ignoreasyncerrors){
			A4J.AJAX.replacePage(req);
		}
	*/
};
});
</script>