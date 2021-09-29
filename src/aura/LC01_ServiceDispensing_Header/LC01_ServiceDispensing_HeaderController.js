({
	backToConfigurator : function(cmp, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : cmp.get("v.configurator"),
            componentAttributes: {
                qliId : cmp.get("v.qli").Id
            }
        });
        evt.fire();
    }
})