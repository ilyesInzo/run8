({     
    doInit : function(cmp) {
        var action = cmp.get("c.getdisplayContractReminder");
        action.setParams({
            oppId : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
        	var _response = response.getReturnValue();
            if(_response != null){
            	cmp.set("v.displayContractReminder", _response.displayContractReminder);
            	cmp.set("v.idContract", _response.contractId);
            }
        });
        $A.enqueueAction(action);
    },     
})