({
	init : function(component, event, helper) {
        
        var action = component.get("c.getContactBadges");
        
            action.setParams({
                "contactId": component.get("v.contactId") 
            });
            
            action.setCallback(this, function(response){
				var state = response.getState();
            	if (state === "SUCCESS"){
                    var contactBadges = response.getReturnValue();
                    if(contactBadges != null){
                        console.log('eee: ' + contactBadges);
                        console.log(contactBadges[0]);
                        console.log('eee2: ' + contactBadges[0].familyBadge);
                        console.log('eee3: ' + contactBadges[0].userbadges);
                        //console.log('eee4: ' + contactBadges[0].userbadges[0]);
                        //console.log('eee5: ' + contactBadges[0].userbadges[0].contactId);
                        component.set("v.contactBadges",contactBadges);
					}
                }
			});
        
        $A.enqueueAction(action);

    },
    
    openRankList : function(component, event, helper) {
        
        var target = event.currentTarget;
		var badgeName = target.dataset.record;
        
        $A.createComponent( 'c:LC02_DisplayListRank', {
            	badgeName : badgeName,
            	contactId : component.get("v.contactId")
            },
            function(modalComponent, status, errorMessage) {
                if (status === "SUCCESS") {
                    //Appending the newly created component in div
                    console.log('777777');
                    var body = component.find( 'showChildModal' ).get("v.body");
                    body.push(modalComponent);
                    component.find( 'showChildModal' ).set("v.body", body);
                } else if (status === "INCOMPLETE") {
                	console.log('Server issue or client is offline.');
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
        				"type": "Error",
        				"message": "Server issue or client is offline."
    				});
    				toastEvent.fire();
                } else if (status === "ERROR") {
                	console.log('error');
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
        				"type": "Error",
        				"message": "Uncknown Error."
    				});
    				toastEvent.fire();
                }
            }
        );
        
    }
    
})