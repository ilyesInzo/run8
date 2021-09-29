({
	handleEvent: function(cmp, event, helper) {
        helper.openModal(cmp, event);
    },
    
    savechanges :  function(cmp, event, helper) {
    	var action = cmp.get("c.saveSelectedConfig");
        action.setParams({
            so : cmp.get("v.selectedconfig")
        });
		action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
            	var config = actionResult.getReturnValue();
            	//config['sobjectType'] = 'PM_Selected_Tubes_Config__c';
            	//cmp.set("v.savedConfig", actionResult.getReturnValue());
            	console.log('*****SAVED*****' + actionResult.getReturnValue());
            	helper.closeModal(cmp, event);
            } else {
	                console.log('AN ERROR OCCURED saveSelectedConfig ' + state);
            }     
            
            console.log('*****SelectedTubeEvent*****' + $A.get("e.c:LE00_SelectedTube"));
            $A.get("e.c:LE00_SelectedTube").fire();     
		});
		$A.enqueueAction(action);
    },
    
    cancelchanges :  function(cmp, event, helper) {
    	//config.Number_of_ref_per_run__c = null;
    	//config.Number_of_tubes_per_artwork_in_Ku__c = null;
    	cmp.find("Number_of_ref_per_run__c").set("v.value", null);
    	cmp.find("Number_of_tubes_per_artwork_in_Ku__c").set("v.value", null);
    	var action = cmp.get("c.saveSelectedConfig");
    	var config = cmp.get("v.selectedconfig");
        action.setParams({
            so : config
        });
		action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
            	var config = actionResult.getReturnValue();
            	console.log('*****CANCELLED*****' + actionResult.getReturnValue());
            	
            	helper.closeModal(cmp, event);
            } else {
	                console.log('AN ERROR OCCURED saveSelectedConfig ' + state);
            }          
            console.log('*****SelectedTubeEvent*****' + $A.get("e.c:LE00_SelectedTube"));
            $A.get("e.c:LE00_SelectedTube").fire();
		});
		$A.enqueueAction(action);
    }
    
})