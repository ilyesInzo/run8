({
	init : function(component, event, helper) {
		var userId = $A.get("$SObjectType.CurrentUser.Id");
        var action = component.get("c.getContactInfos");
        
            action.setParams({
                "userId": userId 
            });
            
            action.setCallback(this, function(response){
				var state = response.getState();
            	if (state === "SUCCESS"){
                    var contact = response.getReturnValue();
                    if(contact != null){
                        component.set("v.contactId",contact.Id );
                        component.set("v.contactName",contact.Name );
                        component.set("v.contactRank",contact.Rank_Name__c );
                        component.set("v.contactTotalPoints",contact.Total_won_points__c );
                        component.set("v.contactNbrBadge",contact.Nb_of_badges__c );
                        
                        console.log(component.get("v.contactId"));
                        console.log(component.get("v.contactRank"));
                        console.log(component.get("v.contactTotalPoints"));
                        console.log(component.get("v.contactNbrBadge"));
                        
                        
                    }
            	} 
        	});
        	$A.enqueueAction(action);
	},
    
    openRankPage : function(component, event, helper) {
        
        var cmpCall = "c:LC02_DetailRank";
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : cmpCall,
            componentAttributes: {
                contactId : component.get("v.contactId"),
                //contactName : component.get("v.contactName"),
                contactTotalPoints : component.get("v.contactTotalPoints"),
                contactNbrBadge : component.get("v.contactNbrBadge"),
                contactRank : component.get("v.contactRank")
            }
        });
        evt.fire();
        
	}
})