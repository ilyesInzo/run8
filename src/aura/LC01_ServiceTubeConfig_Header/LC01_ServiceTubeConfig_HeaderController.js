({
	backToProductConfig: function(cmp, event, helper) {
		// TODO : obtain component name dynamically
		if(cmp.get("v.configPageName")){
	        var evt = $A.get("e.force:navigateToComponent");
	        evt.setParams({
	            componentDef : cmp.get("v.configPageName"),    //"c:LC01_ProductConfig_EU_TubePlastic",
	            componentAttributes: {
	                qliId : cmp.get("v.qli").Id
	            }
	        });
	        evt.fire();
        }
    },
	gotoServiceTubeDetails : function(cmp, event, helper) {	
	
		if(cmp.get("v.serviceId")){
	        var evt = $A.get("e.force:navigateToComponent");
	        evt.setParams({
	            componentDef : "c:LC01_ServiceTubeDetails",
	            componentAttributes: {
	                qliId : cmp.get("v.qli").Id,
	                configId : cmp.get("v.configId"),
		            configPageName : cmp.get("v.configPageName")
	            }
	        });
	        evt.fire();
        }
         

    },
    backToServices : function(cmp, event, helper) {
    	if(cmp.get("v.serviceId")){
	        var evt = $A.get("e.force:navigateToComponent");
	        evt.setParams({
	            componentDef : "c:LC01_ServiceTubeConfig",
	            componentAttributes: {
	                qliId : cmp.get("v.qli").Id,
	                configId : cmp.get("v.configId"),
		            configPageName : cmp.get("v.configPageName")
	            }
	        });
	        evt.fire();
        }
    }
})