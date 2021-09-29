({
	unlockBoxes : function(cmp) {
		//var finalReviewPrices = cmp.get("v.FinalReviewPrices");//used to get empty fields to keep them locked
		if(cmp.find("QP1") != undefined){			
			cmp.find("QP7").set("v.disabled", false);
			cmp.find("QP6").set("v.disabled", false); 
			cmp.find("QP5").set("v.disabled", false); 
			cmp.find("QP4").set("v.disabled", false); 
			cmp.find("QP3").set("v.disabled", false); 
			cmp.find("QP2").set("v.disabled", false); 
			cmp.find("QP1").set("v.disabled", false); 
						 
			 cmp.find("MOQ1").set("v.disabled", false); 
			 cmp.find("MOQ2").set("v.disabled", false); 
			 cmp.find("MOQ3").set("v.disabled", false); 
			 cmp.find("MOQ4").set("v.disabled", false); 
			 cmp.find("MOQ5").set("v.disabled", false); 
			 cmp.find("MOQ6").set("v.disabled", false); 
			 cmp.find("MOQ7").set("v.disabled", false);
			// console.log('================');
			// console.log(cmp.find("QP1").get("v.value")==undefined || cmp.find("QP1").get("v.value") <=0 );
			 if(!(cmp.find("QP1").get("v.value")==undefined || cmp.find("QP1").get("v.value") <=0)) cmp.find("CB1").set("v.disabled", false); 
			 if(!(cmp.find("QP2").get("v.value")==undefined || cmp.find("QP2").get("v.value") <=0)) cmp.find("CB2").set("v.disabled", false); 
			 if(!(cmp.find("QP3").get("v.value")==undefined || cmp.find("QP3").get("v.value") <=0)) cmp.find("CB3").set("v.disabled", false); 
			 if(!(cmp.find("QP4").get("v.value")==undefined || cmp.find("QP4").get("v.value") <=0)) cmp.find("CB4").set("v.disabled", false); 
			 if(!(cmp.find("QP5").get("v.value")==undefined || cmp.find("QP5").get("v.value") <=0)) cmp.find("CB5").set("v.disabled", false); 
			 if(!(cmp.find("QP6").get("v.value")==undefined || cmp.find("QP6").get("v.value") <=0)) cmp.find("CB6").set("v.disabled", false); 
			 if(!(cmp.find("QP7").get("v.value")==undefined || cmp.find("QP7").get("v.value") <=0)) cmp.find("CB7").set("v.disabled", false);
		}
	},
	
	lockBoxes:function(cmp){
		if(cmp.find("QP1") != undefined ){
			cmp.find("QP7").set("v.disabled", true); 
		     cmp.find("QP6").set("v.disabled", true); 
			 cmp.find("QP5").set("v.disabled", true); 
			 cmp.find("QP4").set("v.disabled", true); 
			 cmp.find("QP3").set("v.disabled", true); 
			 cmp.find("QP2").set("v.disabled", true); 
			 cmp.find("QP1").set("v.disabled", true); 
			 
			 cmp.find("MOQ1").set("v.disabled", true); 
			 cmp.find("MOQ2").set("v.disabled", true); 
			 cmp.find("MOQ3").set("v.disabled", true); 
			 cmp.find("MOQ4").set("v.disabled", true); 
			 cmp.find("MOQ5").set("v.disabled", true); 
			 cmp.find("MOQ6").set("v.disabled", true); 
			 cmp.find("MOQ7").set("v.disabled", true);
			 
			 cmp.find("CB1").set("v.disabled", true); 
			 cmp.find("CB2").set("v.disabled", true); 
			 cmp.find("CB3").set("v.disabled", true); 
			 cmp.find("CB4").set("v.disabled", true); 
			 cmp.find("CB5").set("v.disabled", true); 
			 cmp.find("CB6").set("v.disabled", true); 
			 cmp.find("CB7").set("v.disabled", true);
		}
		 
	},

	round:function(cmp){
		if(cmp.find("QP1") != undefined ){

			 if(cmp.find("QP1").get("v.value")!=undefined && cmp.find("QP1").get("v.value") != Math.trunc(cmp.find("QP1").get("v.value")) && cmp.find("QP1").get("v.value").toFixed(2) != cmp.find("QP1").get("v.value")) cmp.find("QP1").set("v.value", cmp.find("QP1").get("v.value").toFixed(2)); 
			 if(cmp.find("QP2").get("v.value")!=undefined && cmp.find("QP2").get("v.value") != Math.trunc(cmp.find("QP2").get("v.value")) && cmp.find("QP2").get("v.value").toFixed(2) != cmp.find("QP2").get("v.value")) cmp.find("QP2").set("v.value", cmp.find("QP2").get("v.value").toFixed(2)); 
			 if(cmp.find("QP3").get("v.value")!=undefined && cmp.find("QP3").get("v.value") != Math.trunc(cmp.find("QP3").get("v.value")) && cmp.find("QP3").get("v.value").toFixed(2) != cmp.find("QP3").get("v.value")) cmp.find("QP3").set("v.value", cmp.find("QP3").get("v.value").toFixed(2)); 
			 if(cmp.find("QP4").get("v.value")!=undefined && cmp.find("QP4").get("v.value") != Math.trunc(cmp.find("QP4").get("v.value")) && cmp.find("QP4").get("v.value").toFixed(2) != cmp.find("QP4").get("v.value")) cmp.find("QP4").set("v.value", cmp.find("QP4").get("v.value").toFixed(2)); 
			 if(cmp.find("QP5").get("v.value")!=undefined && cmp.find("QP5").get("v.value") != Math.trunc(cmp.find("QP5").get("v.value")) && cmp.find("QP5").get("v.value").toFixed(2) != cmp.find("QP5").get("v.value")) cmp.find("QP5").set("v.value", cmp.find("QP5").get("v.value").toFixed(2)); 
			 if(cmp.find("QP6").get("v.value")!=undefined && cmp.find("QP6").get("v.value") != Math.trunc(cmp.find("QP6").get("v.value")) && cmp.find("QP6").get("v.value").toFixed(2) != cmp.find("QP6").get("v.value")) cmp.find("QP6").set("v.value", cmp.find("QP6").get("v.value").toFixed(2)); 
			 if(cmp.find("QP7").get("v.value")!=undefined && cmp.find("QP7").get("v.value") != Math.trunc(cmp.find("QP7").get("v.value")) && cmp.find("QP7").get("v.value").toFixed(2) != cmp.find("QP7").get("v.value")) cmp.find("QP7").set("v.value", cmp.find("QP7").get("v.value").toFixed(2));
		}
		
		if(cmp.find("QP1EXW") != undefined ){
			if(cmp.find("QP1EXW").get("v.value")!=undefined && cmp.find("QP1EXW").get("v.value") != Math.trunc(cmp.find("QP1EXW").get("v.value")) && cmp.find("QP1EXW").get("v.value").toFixed(2) != cmp.find("QP1EXW").get("v.value")) cmp.find("QP1EXW").set("v.value", cmp.find("QP1EXW").get("v.value").toFixed(2)); 
			 if(cmp.find("QP2EXW").get("v.value")!=undefined && cmp.find("QP2EXW").get("v.value") != Math.trunc(cmp.find("QP2EXW").get("v.value")) && cmp.find("QP2EXW").get("v.value").toFixed(2) != cmp.find("QP2EXW").get("v.value")) cmp.find("QP2EXW").set("v.value", cmp.find("QP2EXW").get("v.value").toFixed(2)); 
			 if(cmp.find("QP3EXW").get("v.value")!=undefined && cmp.find("QP3EXW").get("v.value") != Math.trunc(cmp.find("QP3EXW").get("v.value")) && cmp.find("QP3EXW").get("v.value").toFixed(2) != cmp.find("QP3EXW").get("v.value")) cmp.find("QP3EXW").set("v.value", cmp.find("QP3EXW").get("v.value").toFixed(2)); 
			 if(cmp.find("QP4EXW").get("v.value")!=undefined && cmp.find("QP4EXW").get("v.value") != Math.trunc(cmp.find("QP4EXW").get("v.value")) && cmp.find("QP4EXW").get("v.value").toFixed(2) != cmp.find("QP4EXW").get("v.value")) cmp.find("QP4EXW").set("v.value", cmp.find("QP4EXW").get("v.value").toFixed(2)); 
			 if(cmp.find("QP5EXW").get("v.value")!=undefined && cmp.find("QP5EXW").get("v.value") != Math.trunc(cmp.find("QP5EXW").get("v.value")) && cmp.find("QP5EXW").get("v.value").toFixed(2) != cmp.find("QP5EXW").get("v.value")) cmp.find("QP5EXW").set("v.value", cmp.find("QP5EXW").get("v.value").toFixed(2)); 
			 if(cmp.find("QP6EXW").get("v.value")!=undefined && cmp.find("QP6EXW").get("v.value") != Math.trunc(cmp.find("QP6EXW").get("v.value")) && cmp.find("QP6EXW").get("v.value").toFixed(2) != cmp.find("QP6EXW").get("v.value")) cmp.find("QP6EXW").set("v.value", cmp.find("QP6EXW").get("v.value").toFixed(2)); 
			 if(cmp.find("QP7EXW").get("v.value")!=undefined && cmp.find("QP7EXW").get("v.value") != Math.trunc(cmp.find("QP7EXW").get("v.value")) && cmp.find("QP7EXW").get("v.value").toFixed(2) != cmp.find("QP7EXW").get("v.value")) cmp.find("QP7EXW").set("v.value", cmp.find("QP7EXW").get("v.value").toFixed(2));
		}
		
		if(cmp.find("QP1Transport") != undefined){
			 if(cmp.find("QP1Transport").get("v.value")!=undefined && cmp.find("QP1Transport").get("v.value") != Math.trunc(cmp.find("QP1Transport").get("v.value")) && cmp.find("QP1Transport").get("v.value").toFixed(2) != cmp.find("QP1Transport").get("v.value")) cmp.find("QP1Transport").set("v.value", cmp.find("QP1Transport").get("v.value").toFixed(2)); 
			 if(cmp.find("QP2Transport").get("v.value")!=undefined && cmp.find("QP2Transport").get("v.value") != Math.trunc(cmp.find("QP2Transport").get("v.value")) && cmp.find("QP2Transport").get("v.value").toFixed(2) != cmp.find("QP2Transport").get("v.value")) cmp.find("QP2Transport").set("v.value", cmp.find("QP2Transport").get("v.value").toFixed(2)); 
			 if(cmp.find("QP3Transport").get("v.value")!=undefined && cmp.find("QP3Transport").get("v.value") != Math.trunc(cmp.find("QP3Transport").get("v.value")) && cmp.find("QP3Transport").get("v.value").toFixed(2) != cmp.find("QP3Transport").get("v.value")) cmp.find("QP3Transport").set("v.value", cmp.find("QP3Transport").get("v.value").toFixed(2)); 
			 if(cmp.find("QP4Transport").get("v.value")!=undefined && cmp.find("QP4Transport").get("v.value") != Math.trunc(cmp.find("QP4Transport").get("v.value")) && cmp.find("QP4Transport").get("v.value").toFixed(2) != cmp.find("QP4Transport").get("v.value")) cmp.find("QP4Transport").set("v.value", cmp.find("QP4Transport").get("v.value").toFixed(2)); 
			 if(cmp.find("QP5Transport").get("v.value")!=undefined && cmp.find("QP5Transport").get("v.value") != Math.trunc(cmp.find("QP5Transport").get("v.value")) && cmp.find("QP5Transport").get("v.value").toFixed(2) != cmp.find("QP5Transport").get("v.value")) cmp.find("QP5Transport").set("v.value", cmp.find("QP5Transport").get("v.value").toFixed(2)); 
			 if(cmp.find("QP6Transport").get("v.value")!=undefined && cmp.find("QP6Transport").get("v.value") != Math.trunc(cmp.find("QP6Transport").get("v.value")) && cmp.find("QP6Transport").get("v.value").toFixed(2) != cmp.find("QP6Transport").get("v.value")) cmp.find("QP6Transport").set("v.value", cmp.find("QP6Transport").get("v.value").toFixed(2)); 
			 if(cmp.find("QP7Transport").get("v.value")!=undefined && cmp.find("QP7Transport").get("v.value") != Math.trunc(cmp.find("QP7Transport").get("v.value")) && cmp.find("QP7Transport").get("v.value").toFixed(2) != cmp.find("QP7Transport").get("v.value")) cmp.find("QP7Transport").set("v.value", cmp.find("QP7Transport").get("v.value").toFixed(2));		
		}
		 
	}	, 

	 hidespinner3: function (cmp) {
       
        $A.util.addClass(cmp.find("mySpinner3"), "slds-hide");
    },
    showspinner: function (cmp) {
       
        $A.util.removeClass(cmp.find("mySpinner3"), "slds-hide");
    }, 

     calcdeltaX: function(cmp, event, helper, number) {
        
    	console.log('@@ dans calcdelta success start');
    	this.showspinner(cmp);
        this.round(cmp)   //Arthur : If integer -> no change, else -> tofixed(2)
    	this.lockBoxes(cmp);	 
	    cmp.set("v.isActive", false);
        
       
        
    	//console.log('@@qama avant if '+finalReviewPrices) ;
    	//Added by maryem QADA to delete prices if the corresponding mock isnt set

        var finalReviewPrices = cmp.get("v.FinalReviewPrices");

    	if(finalReviewPrices != undefined){
    	//console.log('@@qama dans if '+finalReviewPrices) ;
    		   // Malha
	         /*var transportPrice = cmp.get("v.FinalReviewPrices["+number+"].Transport_Price__c");
	            var exwPrice = cmp.get("v.FinalReviewPrices["+number+"].EXW_Price__c") ;
	            var quotedPrice = cmp.get("v.FinalReviewPrices["+number+"].Quoted_Price__c") ;
	            if(transportPrice != undefined && exwPrice != undefined && cmp.get("v.productLine") != 'Tubes'){
	                cmp.set("v.FinalReviewPrices["+number+"].Quoted_Price__c", transportPrice + exwPrice);
	            }else if(transportPrice != undefined && quotedPrice != undefined){
	                cmp.set("v.FinalReviewPrices["+number+"].EXW_Price__c", quotedPrice - transportPrice);
	            }*/
                
	    		if(finalReviewPrices[number].MOQ_Units__c <=0 ){
	    			finalReviewPrices[number].Quoted_Price__c=  null;
	    			finalReviewPrices[number].Selected__c=  null;
	    		}
	    		if(finalReviewPrices[number].Quoted_Price__c <=0){
	    			finalReviewPrices[number].Selected__c=  null;
	    		}
	    	  
	    	 
    	}  
    	
        
        var action = cmp.get("c.updateFinalReviewPricesX");
        
            action.setParams({
                
                "FinalReviewPricesList": finalReviewPrices ,
                "num" : number
                     
            });
            
            action.setCallback(this, function(response){
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {
                	console.log('@@ dans calcdelta success');
                   // console.log('Updated Final Review Prices ='+response.getReturnValue());
                   
                   // Malha
                    cmp.set("v.FinalReviewPrices["+number+"]",response.getReturnValue()[number]);     
                    cmp.set("v.isActive", true);
                   
                                             
                    this.unlockBoxes(cmp);
                    this.hidespinner3(cmp);	

                      
                } 
                else{
                console.log('@@ dans calcdelta error');
                	console.log(response.getError()[0].pageErrors[0].message);
					var toastEvent = $A.get("e.force:showToast");
					/*toastEvent.setParams({ 
						message: response.getError()[0].pageErrors[0].message,
						//message: "Failed to save final price. Please review your data!",
					        type : "error"
					    });
					toastEvent.fire();	*/


					 if(!response.getError()[0].pageErrors[0].message.includes("Quote items are not updatable when the Quote status is Won, Lost or Killed.")){
                        toastEvent.setParams({ 
                        message: response.getError()[0].pageErrors[0].message,
                        //message: "Failed to save final price. Please review your data!",
                            type : "error"
                        });
                        toastEvent.fire();
                    }
                    else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                              message: "No possibilities to modify the quote line item because the status is Won/lost/killed",
                                type : "error"
                            });
                        toastEvent.fire();  
                    }

		          cmp.set("v.isActive", true);
                    helper.hidespinner3(cmp);
		            this.unlockBoxes(cmp);
		             
               }
               
              // $A.get('e.force:refreshView').fire();//!
            }); 
            $A.enqueueAction(action);
         	
    } 

})