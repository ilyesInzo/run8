({
   /* doInit2 : function(component, event, helper) {
	
        var account = component.get("v.simpleRecord");
        
        console.log("account : " + account);
        console.log(component.get("v.recordId"));
        var dateLastCall = account.Tech_dateOfTheLastHeliosCall__c;
        
        if(dateLastCall.setMinutes(20) < Date.now()){
            
            account.Tech_dateOfTheLastHeliosCall__c = Date.now();
			component.set("v.simpleRecord",account);     
            
        	component.find("recordLoader").saveRecord($A.getCallback(function(saveResult) {
            	if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                	console.log("Save completed successfully.");
            	} 
                else{
                	console.log("User is offline, device doesn't support drafts.");
        			}
            }));
        }                                                          
                                                                     
    },*/
    
    doInit : function(component, event, helper) {
	
       /* var account = component.get("v.simpleRecord");
        
        console.log(account);
        console.log(component.get("v.recordId"));
        
        var action = component.get("c.editDateHeliosCall");
        action.setParams({
            accountId : component.get("v.recordId")            
        });
        action.setCallback(this, function(response) {
        
        		var state = response.getState();
	            if (state === "SUCCESS") {
		      		   console.log("OK"); 
                       $A.get('e.force:refreshView').fire();
	            } else {
	            
				    var toastEvent = $A.get("e.force:showToast");
				    toastEvent.setParams({
				        message: "Failed to Call Helios ",
				        type : "error"
				    });
				    toastEvent.fire();
	            }

        });
        $A.enqueueAction(action); */  
        helper.timedRefresh(component, event, helper);
    },
    
    editRecordHandler : function(component, event, helper) {
	component.set("v.curView", "editView");
    }
})