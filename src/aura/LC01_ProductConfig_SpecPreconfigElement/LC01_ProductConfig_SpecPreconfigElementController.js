({
	updateConfig : function(component, event, helper) {
		var tr = component.get("v.selectedConfig");
		var action = component.get("c.setFieldsValue");
        action.setParams({
            selectedConfig : tr, 
            configuration: component.get("v.preconfig.Configuration__c"),
            configuration2: component.get("v.preconfig.Configuration_2__c"),
            configuration3: component.get("v.preconfig.Configuration_3__c"),
            configuration4: component.get("v.preconfig.Configuration_4__c")
            
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                component.set('v.selectedConfig', '');
                component.set('v.selectedConfig', response.getReturnValue());
                var clickPreconfig = $A.get("e.c:LC01_SpecPreconfigEvent");
		        clickPreconfig.setParams({
		            "selectedPreconfig" : component.get("v.preconfig"),
		            "selectedConfig" : component.get("v.selectedConfig")
		        });
		        clickPreconfig.fire();
                component.set("v.selectedConfig.Is_from_preconfig__c", false);

            }
        }
        );
        $A.enqueueAction(action);
 
	}
})