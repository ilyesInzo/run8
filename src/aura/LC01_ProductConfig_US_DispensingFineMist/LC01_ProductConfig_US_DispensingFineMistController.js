({
     init : function(cmp, event, helper) {
		if(cmp.get("v.qli").Id && event.getParam("value").Id && !event.getParam("oldValue").Id){
        var action = cmp.get("c.getSelectedConfig");
        var qli = cmp.get("v.qli");
        var mapfilters = {
        'Quote_item__c' : qli.Id,
        'Product_Segment__c' : qli.Product_Sub_segment__c,
        'Location__c' : qli.Location__c
        }        
        action.setParams({
        	so : cmp.get("v.selectedDispensingConfig"),
            mapfilters : mapfilters
        });
        action.setCallback(this, function(response) {
        	console.log("selectedDispensingConfig", response.getReturnValue()); 
        	cmp.set("v.selectedDispensingConfig", response.getReturnValue());
        	        	
        });
        $A.enqueueAction(action);
        }
    },
    handleCollapseEvent : function(component, event, helper) {
        // 1- Get Collapse Event params
        var fromSectionName = event.getParam("name"); 
        var newStateFromOtherSection = event.getParam("isOpen"); //component.get("v.isOpen");
        console.log('############## Event received from Section: '+fromSectionName+" new state: "+newStateFromOtherSection);
        // 2- update collapseStatus
        
        var collapseStatus = component.get("v.collapseStatus");
        for (var k in collapseStatus){
            if (newStateFromOtherSection === true && k != fromSectionName.split(' ').join('_')) {
                collapseStatus[k] = false;
            }
        }
        component.set("v.collapseStatus", collapseStatus);
    }
})