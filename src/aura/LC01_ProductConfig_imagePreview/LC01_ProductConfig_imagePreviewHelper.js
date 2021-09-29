({
    refreshProductImage : function(cmp) {
        var action = cmp.get("c.refreshProductImage");
        action.setParams({
            quoteItemId : cmp.get("v.qli.Id")          
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            console.log('****state*****' + state);
            if (state === "SUCCESS") {
                var errorMessage = actionResult.getReturnValue();
                //if(errorMessage != null || errorMessage != ''){
                // error 
                cmp.set("v.errorMessage", errorMessage);
                console.log('****errorMessage*****' + errorMessage);
                //}
                //cmp.set("v.display", actionResult.getReturnValue());
            } else {
                //alert("An Error occured" + state);
                cmp.set("v.errorMessage", "An Error occured (" + state+")");
            }          
        });
        $A.enqueueAction(action);
    },
    
    refreshQuoteItem: function(cmp){
        
        var action = cmp.get("c.getQuoteItemById");
        action.setParams({
            quoteItemId : cmp.get("v.qli.Id")          
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            console.log('****state*****' + state);
            if (state === "SUCCESS") {
                cmp.set("v.qli", actionResult.getReturnValue());
                cmp.set("v.showProductImg", true);
                
                var refreshBtn = cmp.find("refreshBtn");
        		refreshBtn.set("v.disabled", false);
            } else {
                //alert("An Error occured" + state);
            }          
        });
        $A.enqueueAction(action); 
    }
})