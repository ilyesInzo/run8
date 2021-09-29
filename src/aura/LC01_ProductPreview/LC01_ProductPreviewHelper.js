({
    getQuoteItemRecordById : function(cmp) {
        // get Quote Line Item record
        var actionGetQLIRecord = cmp.get("c.getQuoteItemRecord");
        actionGetQLIRecord.setParams({
            quoteItemId : cmp.get("v.recordId")          
        });
        actionGetQLIRecord.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            console.log('****state*****' + state);
            if (state === "SUCCESS") {
                cmp.set("v.qli", actionResult.getReturnValue());
            } else {
                alert("An Error occured" + state);
            }          
        });
        $A.enqueueAction(actionGetQLIRecord); 
        
        
    }
})