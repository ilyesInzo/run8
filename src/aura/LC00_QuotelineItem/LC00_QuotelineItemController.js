({
    init : function(cmp, event, helper) {
         
        // get Quote line item
        var action = cmp.get("c.getQuoteItemById");
        action.setParams({
            quoteItemId : cmp.get("v.qliId")
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {              
	            var _qli = response.getReturnValue();
	            cmp.set("v.qli",_qli);
                var cmpEvent = cmp.getEvent("LE00_QuoteLineReady");
                    cmpEvent.setParams({
                        "ready" : true});
                    cmpEvent.fire();
            } else {
	                console.log('AN ERROR OCCURED' + state);
            } 
            
        }); 
        
        $A.enqueueAction(action);
    }
})