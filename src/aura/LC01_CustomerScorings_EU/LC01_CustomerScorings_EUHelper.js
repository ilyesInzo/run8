({
    calculatescore: function(cmp, evt) {
      //check if object is not null and if the changed value is a field and not the object itself
      if(cmp.get("v.qli").Id && !evt.getParam("value").Id){
      
    	  if(!(evt.getParam("oldValue") === undefined && evt.getParam("value") === "")){
		        var action = cmp.get("c.calculatescore");
		        action.setParams({
		            qli : cmp.get("v.qli")
		        });
				action.setCallback(this, function(actionResult) {
		            var state = actionResult.getState();
		            if (state === "SUCCESS") {
		        		cmp.set("v.qli", actionResult.getReturnValue());	
		        		console.log('Customer Scoring SAVE Success');	        		
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
    },
    validatescore: function(cmp, evt, mapopts) {
    	var qli = cmp.get("v.qli");
    	
    	var scoreval = (
    	(mapopts["disabledfields"].indexOf("Customer_Type__c") != -1 || (qli.Customer_Type__c)) && 
    	(mapopts["disabledfields"].indexOf("Business_at_other_product_line__c") != -1 || (qli.Business_at_other_product_line__c)) && 
    	(mapopts["disabledfields"].indexOf("Payment_terms__c") != -1 || (qli.Payment_terms__c)) && 
    	(mapopts["disabledfields"].indexOf("Required_level_of_documentation__c") != -1 || (qli.Required_level_of_documentation__c)) && 
    	(mapopts["disabledfields"].indexOf("Monthly_overdue_DSO__c") != -1 || (qli.Monthly_overdue_DSO__c)) && 
    	(mapopts["disabledfields"].indexOf("Quality_requirement__c") != -1 || (qli.Quality_requirement__c)) && 
    	(mapopts["disabledfields"].indexOf("Customer_end_of_year_rebate__c") != -1 || (qli.Customer_end_of_year_rebate__c)) && 
    	(mapopts["disabledfields"].indexOf("Customer_EBB_rate__c") != -1 || (qli.Customer_EBB_rate__c))
    	)?true:false;
    	
	    cmp.set("v.validatescore", scoreval);
    	
    }
})