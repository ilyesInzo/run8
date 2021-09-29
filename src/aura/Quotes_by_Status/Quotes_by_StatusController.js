({
    doInit : function(component, event, helper) {

    	var action = component.get("c.isAllowed");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });

        // Create a callback that is executed after 
        // the server-side action returns

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
            	component.set('v.isAllowed', response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        
        if(component.get("v.isAllowed") == true){
        	helper.createChart(component);
        }        
    }
})