({
    calculateservicescore: function(cmp, evt) {
      //check if object is not null and if the changed value is a field and not the object itself
      if(cmp.get("v.qli").Id && !evt.getParam("value").Id){
    	  if(!(evt.getParam("oldValue") === undefined && evt.getParam("value") === "")){
	        var action = cmp.get("c.calculateservicescore");
	        action.setParams({
	            qli : cmp.get("v.qli")
	        });
			action.setCallback(this, function(actionResult) {
	            var state = actionResult.getState();
	            if (state === "SUCCESS") {
	        		cmp.set("v.qli", actionResult.getReturnValue());
					console.log('Service Scoring SAVE Success');	
	            } else {
		                console.log('AN ERROR OCCURED' + state);
		                if(actionResult.getError()[0].pageErrors[0].message.includes("Quote items are not updatable when the Quote status is Won, Lost or Killed.")){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                        message: "No possibilities to modify the quote line item because the status is Won/lost/killed",
                                        type : "error"
                                    });
                                toastEvent.fire();
                                console.log('AN ERROR OCCURED saveSelectedConfig ' + state);
                                $A.get('e.force:refreshView').fire();
                        }
	            }          
			});
			$A.enqueueAction(action);
    	  }        
        }
    }
})