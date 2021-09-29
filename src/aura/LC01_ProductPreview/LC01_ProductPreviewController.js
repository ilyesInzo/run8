({
	init: function(cmp, event, helper) {
    	// check display button
        var action = cmp.get("c.displaybuttonvalidation");
        action.setParams({
            quoteItemId : cmp.get("v.recordId")          
        });
		action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            console.log('****state*****' + state);
            if (state === "SUCCESS") {
        		cmp.set("v.display", actionResult.getReturnValue());
            } else {
                alert("An Error occured" + state);
            }          
		});
		$A.enqueueAction(action); 
        //if(cmp.get("v.display")){
            // get Quote Line Item record            
            helper.getQuoteItemRecordById(cmp);
            //var qli = cmp.get("v.qli");
            //cmp.set("v.finalLookImageDocId", qli.Product_Final_Look__c);
        //}
        
        
    }
})