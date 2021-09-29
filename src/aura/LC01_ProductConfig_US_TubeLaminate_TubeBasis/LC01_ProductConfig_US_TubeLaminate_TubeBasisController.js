({

    savechanges :  function(cmp, event, helper) {
    	var action = cmp.get("c.saveSelectedConfig");
        action.setParams({
            so : cmp.get("v.selectedtubeconfig")
        });
		action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
            	var config = actionResult.getReturnValue(); 
            	console.log('*****SAVED*****' + actionResult.getReturnValue());
            } else {
                alert("An Error occured" + state);
            }          
		});
		$A.enqueueAction(action);
    }
})