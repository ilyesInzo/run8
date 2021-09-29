({
    init : function(cmp, event, helper) {
       
		if(cmp.get("v.qli").Id && event.getParam("value").Id && !event.getParam("oldValue").Id){
        var action = cmp.get("c.getSelectedConfig");	    
        var qli = cmp.get("v.qli");
        var mapfilters = {
        'Quote_item__c' : qli.Id,
        'Tube_Segment__c' : qli.Product_Sub_segment__c,
        'Location__c' : qli.Location__c,
        'PM_Selected_Tubes_Config__c' : cmp.get("v.configId")
        }
                
        action.setParams({
        	so : cmp.get("v.servicetube"),
            mapfilters : mapfilters
        });
                
        action.setCallback(this, function(response) {
        	var config = response.getReturnValue();
        	config['sobjectType'] = 'PM_Selected_Service_Tubes_Config__c';
        	cmp.set("v.servicetube", config);
        });
        $A.enqueueAction(action);
        }
    }
})