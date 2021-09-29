({
    openCustomerScoring : function(cmp, event, helper) {
    
        var cmpqli = cmp.get("v.qli");
        if(cmpqli.Id){
        var cmpdef = "c:LC01_CustomerScorings_";
        cmpdef += (cmpqli.Location__c)?cmpqli.Location__c:"EU";
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : cmpdef,
            componentAttributes: {
                qliId : cmpqli.Id
            }
        });
        evt.fire();
        }
    },
    
    openDealScoring : function(cmp, event, helper) {
        var cmpqli = cmp.get("v.qli");
        if(cmpqli.Id){
        var cmpdef = "c:LC01_DealScoring_";
        cmpdef += (cmpqli.Location__c)?cmpqli.Location__c:"EU";
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : cmpdef,
            componentAttributes: {
                qliId : cmpqli.Id
            }
        });
        evt.fire();
        }
    },
    
    openServiceScoring: function(cmp, event, helper) {
        var cmpqli = cmp.get("v.qli");
        if(cmpqli.Id){
        var cmpdef = "c:LC01_ServiceScoring_";
        cmpdef += (cmpqli.Location__c)?cmpqli.Location__c:"EU";
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : cmpdef,
            componentAttributes: {
                qliId : cmpqli.Id
            }
        });
        evt.fire();
        }
    }
})