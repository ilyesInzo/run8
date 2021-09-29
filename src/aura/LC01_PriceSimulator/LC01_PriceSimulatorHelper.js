({
	fetchMarketOfApplication : function(component){
        var action = component.get("c.getPicklistvalues");
        action.setParams({
            'objectName': 'QuoteLineItem',
            'field_apiname': 'Market_Of_Application__c',
            'nullRequired': true // includes --None--
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                component.set("v.marketOfApplicationList", a.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    
    openProductConfigPage: function(cmp) {
         var productSubSegment = cmp.get("v.selectedSubProduct");
		console.log("MarketOfApplication"+ cmp.get("v.marketOfApplication"));

         var action = cmp.get("c.createRecords");
        
            action.setParams({
                
                "oppName": cmp.get("v.opportunityName"),
                "accountId"  : cmp.get("v.accountName.Id") , 
                "productSubSegment" : cmp.get("v.selectedSubProduct") ,
                "annualQuantity" : cmp.get("v.annualQuantity") ,
                "marketOfApplication" : cmp.get("v.marketOfApplication"),
                "purefoil" : cmp.get("v.purefoil") 
            });
            
            action.setCallback(this, function(response){
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") { 
                	console.log('+++SUCCESS' + response.getReturnValue());   
                	var result = response.getReturnValue();
                	
                    cmp.set("v.qliID", result.Id);
                    
                    var location = (result.Location__c == '' || result.Location__c == null )? 'EU' : result.Location__c;
                    
                    var evt = $A.get("e.force:navigateToComponent");
			        
                    var pageComponentName = "";
			        
		        	switch (productSubSegment) {
		                case "Plastic Tubes":
                            if(result.Shape__c == 'showPurefoil' && result.Purefoil_Segment__c == true){
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
                        
		            if(pageComponentName != ""){
			            evt.setParams({
			                componentDef : pageComponentName,
			                componentAttributes: {
			                    qliId : result.Id
			                }
			            });
			            evt.fire();   
				    }
               
               
                }
                else if (state === "ERROR"){
                	var errors = response.getError();
                    
                	console.log('+++ERROR' + response.getError());   
                	var message = 'Error';
                	if (errors) {
                    	if (errors[0] && errors[0].message) {
                    		message = errors[0].message;
                    	}
                    }
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                                          message: message ,
                                          type : "error"
                                            });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        	$A.util.removeClass(cmp.find("mySpinner3"), "slds-hide");
    }
    
})