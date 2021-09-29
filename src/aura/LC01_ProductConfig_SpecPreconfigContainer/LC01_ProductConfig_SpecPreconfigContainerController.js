({
	doInit : function(component, event, helper) {
       
		var action = component.get("c.getPreconfig");
        action.setParams({
            location : component.get("v.location"), 
            productSegment: component.get("v.productSubSegment")
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                component.set('v.preconfigList', response.getReturnValue());

            }
        }
        );
        $A.enqueueAction(action);
        
	},

    updateConfig : function(component, event, helper) {

        var selectedPreconfig = event.getParam("selectedPreconfig");
        component.set("v.selectedPreconfig", selectedPreconfig);
       
    }, 

    resetConfigJS : function(component, event, helper) {
        var action = component.get("c.resetConfig");
        action.setParams({
            selectedConfig : component.get("v.selectedConfig")
         
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                component.set('v.selectedConfig', response.getReturnValue());
                var clickPreconfig = $A.get("e.c:LC01_SpecPreconfigEvent");
                clickPreconfig.setParams({
                    "selectedPreconfig" : "",
                    "selectedConfig" : component.get("v.selectedConfig")
                });
                clickPreconfig.fire();

            }
        }
        );
        $A.enqueueAction(action);
        

    }
})