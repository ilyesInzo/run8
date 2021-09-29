({
	initial : function(component, event, helper) {
       

    },
 	doInit: function(component, event, helper) {
        var layoutEUTube=false;
        if(component.get("v.qli.Location__c")== 'EU' && component.get("v.qli.Product2.Family ")== 'Tubes')
            {
                layoutEUTube=true;
            }
		component.set('v.LayoutEUTube',layoutEUTube);
		helper.initLayout(component, event);

    },
      
    savechanges :  function(cmp, event, helper) {
    	if(cmp.get("v.qli").Id){
	        var action = cmp.get("c.saveSelectedConfig");
	        action.setParams({
	            so : cmp.get("v.qli")
	        });
			action.setCallback(this, function(actionResult) {
	            var state = actionResult.getState();
	            if (state === "SUCCESS") {
	            	var config = actionResult.getReturnValue();
	            	console.log('*****SAVED*****' + actionResult.getReturnValue());
	            } else {
	                alert("An Error occured" + state);
	            }          
			});
			$A.enqueueAction(action); 
    	}
    }
})