({/*
	handleChange : function(cmp, event, helper) {
		var _specificLength = cmp.get("v.specificLength");
		var _map ={'Specific_length_mm__c' : _specificLength};
		var _recordId = cmp.get("v.selectedtubeconfig").Id;
		
		var action = cmp.get("c.saveFields");
        action.setParams({
            SObjectName: 'PM_Selected_Tubes_Config__c',
            mapValues: _map,
            recordId: _recordId
        });
        
        action.setCallback(this, function(response) {
        });
        $A.enqueueAction(action);
	},
	
	handleSavedConfigChanged: function(cmp, event, helper) {
        helper.loadValues(cmp, event);
    },
    savechanges :  function(cmp, event, helper) {
        console.log('LC01_ProductConfig_EU_PlasticTube : savechanges()');
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
    	  
    }*/
})