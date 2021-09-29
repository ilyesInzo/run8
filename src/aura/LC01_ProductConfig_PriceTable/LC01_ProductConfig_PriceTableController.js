({
    handlechange : function(cmp, event, helper) {
     //Ticket 6970 

    if(event.getParam("value") != null)	
	 {
	     if(event.getParam("value").Id){
          helper.getmoqprice(cmp, event);
	     }
	 }
    },
    
    refreshmoq : function(cmp, event, helper) { 
         
         cmp.set("v.moqpricelst", event.getParam("moqList"));
        //console.log("********* PriceTable -> getmoqprice Call********** v.selectedConfig = ", JSON.stringify(cmp.get("v.selectedConfig.Eurocode__c")));
       // helper.getmoqprice(cmp, event);
    },
    
    openDetails : function(cmp, event, helper) {
    	if(cmp.get("v.selectedConfig").Id == undefined || cmp.get("v.qli").Id == undefined ){
			 var toastEventWarning = $A.get("e.force:showToast");
			 toastEventWarning.setParams({
								        message: "Please wait until the page is fully loaded!",
								        type : "warning"
								    });
			 toastEventWarning.fire();	  
			 return;
		 }
        /*commented by maryem because not yet validated and needs to be deployed in prod for another ticket
    	if(cmp.get("v.selectedConfig").Id && cmp.get("v.qli").Id){
			if(confirm('All unsaved data will be lost, do you wish to continue ?')){
				console.log('*****selectedconfig******' + cmp.get("v.selectedConfig")); 
				$A.util.removeClass(cmp.find("mySpinner"), "slds-hide");
				var evt = $A.get("e.force:navigateToComponent");
				evt.setParams({
				    componentDef : 'c:'+cmp.get("v.detailPageComponentName"),
				    componentAttributes: {
				    qliId : cmp.get("v.qli").Id,
				    displayalert : true
				    }
				});
				evt.fire();
			}*/



    	//Commented by Arthur Leriche, plus de save avant d'aller à la prochaine page
    	/*Decommented by maryem because not yet validated and needs to be deployed in prod for another ticket*/
    	if(cmp.get("v.selectedConfig").Id && cmp.get("v.qli").Id){
			if(confirm('Do you want to save the changes?')){
		    	console.log('*****selectedconfig******' + cmp.get("v.selectedConfig")); 
				$A.util.removeClass(cmp.find("mySpinner"), "slds-hide");
				var action = cmp.get("c.saveSelectedConfig");
				action.setParams({
					so : cmp.get("v.selectedConfig")
				});
				action.setCallback(this, function(actionResult) {
					if (actionResult.getState() === "SUCCESS") {
						
			            
		            	var toastEvent = $A.get("e.force:showToast");
					    toastEvent.setParams({
					        message: "Product Configuration was saved successfully.",
					        type : "success"
					    });
					    toastEvent.fire();
						
				        var evt = $A.get("e.force:navigateToComponent");
				        evt.setParams({
				            componentDef : 'c:'+cmp.get("v.detailPageComponentName"),
				            componentAttributes: {
				                qliId : cmp.get("v.qli").Id,
				                displayalert : true
				            }
				        });
				        evt.fire();
		        
						
					} else {
						$A.util.addClass(cmp.find("mySpinner"), "slds-hide");
						if(actionResult.getError()[0].pageErrors[0].message.includes("Quote items are not updatable when the Quote status is Won, Lost or Killed.")){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                        message: "No possibilities to modify the quote line item because the status is Won/lost/killed",
                                        type : "error"
                                    });
                                toastEvent.fire();
                		}
                		else{
					    var toastEvent = $A.get("e.force:showToast");
					    toastEvent.setParams({
					        message: "Failed to save Product Configuration.",
					        type : "error"
					    });
					    toastEvent.fire();
						}
						$A.util.addClass(cmp.find("mySpinner"), "slds-hide");
						console.log('AN ERROR OCCURED saveSelectedConfig ' + actionResult.getState());
					}	            
				});
				$A.enqueueAction(action); 
				/*Decommented by maryem because not yet validated and needs to be deployed in prod for another ticket*/

			}
			else{
						//Commented by Arthur Leriche, le button annuler ne redirige plus vers la page suivante
                /*Decommented by maryem because not yet validated and needs to be deployed in prod for another ticket*/ 
				        var evt = $A.get("e.force:navigateToComponent");
				      
				        evt.setParams({
				            componentDef : 'c:'+cmp.get("v.detailPageComponentName"),
				            componentAttributes: {
				                qliId : cmp.get("v.qli").Id,
				                displayalert : true
				            }
				        });
				        evt.fire();/*Decommented by maryem because not yet validated and needs to be deployed in prod for another ticket*/
			}
		}
    
    }
})