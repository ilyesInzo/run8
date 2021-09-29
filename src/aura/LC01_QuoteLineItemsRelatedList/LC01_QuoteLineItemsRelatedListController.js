({
    doInit : function(component, event, helper) {
        console.log('record:Id: '+component.get("v.recordId"));
/*
        // Prepare the action to load account record
        var action = component.get("c.getQuoteLinesItems");
        action.setParams({"accountId": component.get("v.recordId")});

        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.account", response.getReturnValue());
            } else {
                console.log('Problem getting account, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
        */
    }
})