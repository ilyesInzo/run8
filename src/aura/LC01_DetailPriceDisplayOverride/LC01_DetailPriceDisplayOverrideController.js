({
	saveOverride : function(component, event, helper) {
		console.log(component.get("v.section") +'_'+component.get("v.title")
                   +'_'+component.get("v.moq") +'_'+component.get("v.moqMax")
                   +'_'+component.get("v.overrideValue")
                   +'_'+component.get("v.qliId"));
        var action = component.get("c.getOverridePrice");
        var overridePriceValue = component.get("v.overrideValue");
        if (overridePriceValue != null) {
            console.log('Override price saving.....');
            action.setParams({            
                section : component.get("v.section"),
                title : component.get("v.title"),
                moq : component.get("v.moq"),
                moqMax : component.get("v.moqMax"),
                price : component.get("v.overrideValue"),
                qliId : component.get("v.qliId"),
                tubeId : component.get("v.tubeId"),
                dispensingId : component.get("v.dispensingId")
            });
            console.log(action);
            action.setCallback(this, function(response) {
                console.log(response);
                var message = response.getReturnValue();
                console.log(message);
                if (message == 'SUCCESS') {
                    $A.get('e.force:refreshView').fire();                    
                    console.log('Need rerfresh now...');
                }
                
            });
            $A.enqueueAction(action);           
        }

        
	} 
})