({
	init : function(component, event, helper) {
	
        var action = component.get("c.getlistRankingByBadge");
		console.log(component.get("v.yourPosition"));
        action.setParams({
            "badgeName": component.get("v.badgeName") ,
            "contactId": component.get("v.contactId") 
            });
 
        action.setCallback(this, function(response){
				var state = response.getState();

            	if (state === "SUCCESS"){
                   var badgeList = response.getReturnValue();
                    if(badgeList != null){
                        //component.set("v.badgeName",badgeList[0].Badge__r.Name);
                        component.set("v.badgeList",badgeList);  
                        console.log(component.get("v.badgeList"));
                        if(badgeList.length > 10 ){
                        	component.set("v.yourPosition",badgeList[10]);  
                        }
                        else{
                            component.set("v.end",badgeList.length);
                        }
                    }
                    console.log(component.get("v.yourPosition"));
                }
			});
        
        $A.enqueueAction(action);
        
	},
    
    closeModal : function(component, event, helper) {
    	component.destroy();
    }
})