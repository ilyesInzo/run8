({
	savechanges :  function(cmp, event, helper) {
		
		if(cmp.get("v.selectedconfig").Id){
			cmp.find("saveBtn").set("v.disabled", true);
	        //show spinner
	        $A.util.removeClass(cmp.find("mySpinner"), "slds-hide");

	         $A.get("e.c:LC00_DependentFieldsEvent").fire();
	    	//if(cmp.get("v.selectedconfig").Id){    	
	    	//check if object is not null and if the changed value is a field and not the object itself
	    	//if(cmp.get("v.selectedconfig").Id && !event.getParam("value").Id){
	    		var action = cmp.get("c.saveSelectedConfig");
	    		action.setParams({
	    			so : cmp.get("v.selectedconfig")
	    		});
	    		action.setCallback(this, function(actionResult) {
	    			var state = actionResult.getState();
	    			if (state === "SUCCESS") {

	    				var toastEvent = $A.get("e.force:showToast");
	    				toastEvent.setParams({
	    					message: "Product Configuration was saved successfully.",
	    					type : "success"
	    				});
	    				toastEvent.fire();

	    				var config = actionResult.getReturnValue();
	    				console.log('*****SAVED*****' + actionResult.getReturnValue());

		            	//Lead Time Lotion pumps
		            	/*if(config.Product_Segment__c == 'Lotion pumps' && config.Location__c == 'EU'){
		            		$A.get('e.force:refreshView').fire();
		            	}	  
                        */
					    $A.get('e.force:refreshView').fire();
		            	var action3 = cmp.get("c.getMOQ");
			    		action3.setParams({
			    			'qliId' : cmp.get("v.selectedconfig.Quote_item__c")
			    		});
			    		action3.setCallback(this, function(response) {
			                var state = response.getState();
			                //console.log("********* PriceTable -> getmoqprice ********** state = ", state);
			                var respVal = response.getReturnValue();
			                if (state === "SUCCESS") { 

			                    //console.log("********* PriceTable -> getmoqprice SUCCESS********** respVal: ", respVal);
			                   
			                    var appEvent = $A.get("e.c:LE00_SelectedTube");
						        appEvent.setParams({
						            "moqList" : respVal });
						        appEvent.fire();
			               }
			              });
			    		 $A.enqueueAction(action3);           	
		            	
		            } else {
		            	
		            	var errors = actionResult.getError();		            	
		            	console.log(errors);

		            	if(errors && errors[0] && errors[0].pageErrors  && errors[0].pageErrors[0] && errors[0].pageErrors[0].message && errors[0].pageErrors[0].message.includes("Quote items are not updatable when the Quote status is Won, Lost or Killed.")){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                        message: "No possibilities to modify the quote line item because the status is Won/lost/killed",
                                        type : "error"
                                    });
                                toastEvent.fire();
                                console.log('AN ERROR OCCURED saveSelectedConfig ' + state);
                		}

		            	else if (errors && errors[0] && errors[0].pageErrors   
                           && errors[0].pageErrors[0] && errors[0].pageErrors[0].statusCode
                                 && errors[0].pageErrors[0].statusCode == "FIELD_CUSTOM_VALIDATION_EXCEPTION") {
		            		console.log(errors[0].pageErrors[0].message);
		            		$A.util.addClass(cmp.find("mySpinner"), "slds-hide");
		            		var toastEvent = $A.get("e.force:showToast");
		            		toastEvent.setParams({
		            			message: errors[0].pageErrors[0].message,
		            			type : "error"
		            		});
		            		toastEvent.fire();
		            	}
		            	
		            	else{
		            		$A.util.addClass(cmp.find("mySpinner"), "slds-hide");
		            		var toastEvent = $A.get("e.force:showToast");
		            		toastEvent.setParams({
		            			message: "Failed to save Product Configuration.",
		            			type : "error"
		            		});
		            		toastEvent.fire();
		            		console.log('AN ERROR OCCURED saveSelectedConfig ' + state);
		            	}
		            }        
		           

		            //$A.get("e.c:LE00_SelectedTube").fire();
		        });
	    		$A.enqueueAction(action); 
	    	//}
	    }
	},

	hidespinner: function (cmp, event) {
		cmp.find("saveBtn").set("v.disabled", false);
		$A.util.addClass(cmp.find("mySpinner"), "slds-hide");
	}
})