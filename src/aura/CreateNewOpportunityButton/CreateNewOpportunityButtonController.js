({
     checkUser: function(component, event, helper) {
         var action = component.get("c.checkCreationAccess");
         action.setParams({ accountId : component.get("v.recordId") });
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.allowCreation", result);
            }
         });
         $A.enqueueAction(action);
     }, 
    
     newRecord: function(component, event, helper) {
        var allow = component.get("v.allowCreation"); 
        if(allow == true){
            var recordId = component.get("v.recordId");
            var simpleRecord = component.get("v.simpleRecord");
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": "Opportunity",
                "defaultFieldValues": {
                    'AccountId' : ''+recordId
                }
            });
            createRecordEvent.fire();
        }else{
            component.set("v.showPopup", true);
        }
        
    }, 
    closePopup:function(component,event, helper){
        component.set("v.showPopup", false);
    }
})