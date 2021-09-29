({
	init : function(cmp, event, helper) {
	    var qliId = cmp.get("v.qliId");
		if(qliId){
	        var action = cmp.get("c.getstep");
	        action.setParams({
	        	qliId : qliId
	        });
	        action.setCallback(this, function(response) {
	         
	        	cmp.set("v.step", response.getReturnValue());
	        	        	
	        });
	        $A.enqueueAction(action);
        }
    }
})