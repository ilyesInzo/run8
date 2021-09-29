({
	doInit: function(cmp, event, helper) {
		if(cmp.get("v.qli").Id && event.getParam("value").Id && !event.getParam("oldValue").Id){
	        var action = cmp.get("c.getmarketofapplst"); 
	        var qli = cmp.get("v.qli");
	        action.setParams({
	            Location : qli.Location__c
	        });
			action.setCallback(this, function(actionResult) {
	            var state = actionResult.getState();
	            if (state === "SUCCESS") {
	        		
	        		var options = actionResult.getReturnValue();
	                var opts=[];
	                opts.push({"class": "optionClass", label: "--None--", value: ""});
	                for(var i=0;i< options.length;i++){
	                    opts.push({"class": "optionClass", label: options[i], value: options[i]});
	                }
	                cmp.find("Market_Of_Application__c").set("v.options", opts);
	        		
	        		
	            } else {
		                console.log('AN ERROR OCCURED' + state);
	            }          
			});
			$A.enqueueAction(action);
		}
	},
    openProductConfigPage: function(cmp, event, helper) {
    	var qli = cmp.get("v.qli");
    	console.log( qli);
    	console.log( qli.Customer_Scoring__c);
    	//check scoring
        console.log("quotee : " + qli);
        console.log("quotee : " + qli.Quote.status);
        console.log("quotee : " + qli.copy_quote_status__c);
        
        
    	if((qli.Total_Score__c !=null 
    	&& qli.Customer_Scoring__c != null) || qli.copy_quote_status__c == 'Simulation' ){
    		console.log("QLI", qli);
    		if(qli.Market_Of_Application__c != undefined && qli.Market_Of_Application__c != '' ){   			
    	
    			var evt = $A.get("e.force:navigateToComponent");
       
		        //var productFamily = qli.Product_line__c;
		        console.log("QLI", qli);
		        //Use Sub Segment to show the configuration page
		        var productSubSegment = qli.Product_Sub_segment__c;
		        console.log("## productSubSegment", productSubSegment);
		        var location = (qli.Location__c == '' || qli.Location__c == null )? 'EU' : qli.Location__c;
		        console.log("## location", location);
		        var pageComponentName = "";
		        
		        console.log("## qli.Purefoil_Segment__c", qli.Purefoil_Segment__c );
		        console.log("## qli.Purefoil_Segment__c == true ? ", qli.Purefoil_Segment__c  == true);
		        console.log("## qli.location == 'EU' ",         location == 'EU');
		
		        switch (productSubSegment) {
		            case "Plastic Tubes":
		                if(location == 'EU' && qli.Purefoil_Segment__c == true){
		                    pageComponentName = "c:LC01_ProductConfig_" + location + "_TubePurefoil";
		                }else{
		                    pageComponentName = "c:LC01_ProductConfig_" + location + "_TubePlastic";   
		                }
		                break;
		            case "Laminate Tubes":
		                pageComponentName = "c:LC01_ProductConfig_" + location + "_TubeLaminate";
		                break; 
		            case "Foam pumps":
		                pageComponentName = "c:LC01_ProductConfig_" + location + "_DispensingFoam";
		                break;
		            case "Fine mist pumps":
		                pageComponentName = "c:LC01_ProductConfig_" + location + "_DispensingFineMist";
		                break;
		            case "Lotion pumps":
		                pageComponentName = "c:LC01_ProductConfig_" + location + "_DispensingLotion";
		                break;
		            case "Sampler pumps":
		                pageComponentName = "c:LC01_ProductConfig_" + location + "_DispensingSamplers";
		                break;
		            default: 
		                alert("Please set check the 'Product Line' and the 'Product Sub Segment' and try again!");
		        }
		        console.log("## pageComponentName", pageComponentName);
		        if(pageComponentName != ""){
		            evt.setParams({
		                componentDef : pageComponentName,
		                componentAttributes: {
		                    qliId : cmp.get("v.qli").Id
		                }
		            });
		            evt.fire();   
		        }
    		}else{
    			alert('Please select a market of application!');
    		}    	
    	
    	}else{
    		alert('Please complete all Scoring steps\' before proceeding to product configuration!');
    	}
       
        
    },
    
    saveproductconfig: function(cmp, event, helper) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
       
        var action = cmp.get("c.saveqli");
        action.setParams({
            qli : cmp.get("v.qli")
        });
		action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
        		console.log('****SAVED***');
        		cmp.set("v.qli", actionResult.getReturnValue());
        		
		        $A.get("e.c:LE00_PriceReco").fire();
		        
            } else {               
                var spinner = cmp.find("mySpinner");
                $A.util.addClass(spinner, "slds-hide");                
                
                var errors = actionResult.getError();
                var message = '';
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
                else{
                if (errors) {
                    for(var i=0; i < errors.length; i++) {
                        for(var j=0; errors[i].pageErrors && j < errors[i].pageErrors.length; j++) {
                            message += (message.length > 0 ? '\n' : '') + errors[i].pageErrors[j].message;
                        }
                        if(errors[i].fieldErrors) {
                            for(var fieldError in errors[i].fieldErrors) {
                                var thisFieldError = errors[i].fieldErrors[fieldError];
                                for(var j=0; j < thisFieldError.length; j++) {
                                    message += (message.length > 0 ? '\n' : '') + thisFieldError[j].message;
                                }
                            }
                        }
                        if(errors[i].message) {
                            message += (message.length > 0 ? '\n' : '') + errors[i].message;
                        }
                    }
                } else {
                    message += (message.length > 0 ? '\n' : '') + 'Unknown error';
                }                       
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: message,
                    type : "error"
                });
                toastEvent.fire();  
            } 
            }         
		});
		$A.enqueueAction(action);
    },
        
    hidespinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
    
})