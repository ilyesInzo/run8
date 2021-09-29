({
    openPriceMatrix: function(component, event, helper) {
        var eventNav = $A.get("e.force:navigateToComponent");
        eventNav.setParams({
            componentDef: "c:LC01_Home",
            componentAttributes: {
                opp : null
            }
        });
        eventNav.fire();
    },
})