({
	initiateObjects : function(cmp) {
        // Get Quote
        console.log("LC01_ValidateQuoteController:JsController:Init ");
        var qli = cmp.get("v.qliId");
        var opp = cmp.get("v.oppId");
        console.log("qliId :" + qli);
        console.log("oppId :" + opp);
        var action = cmp.get("c.initiateObjects");
        action.setParams({
            quoteItemId : qli,
            opportunityId : opp
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if(state === "SUCCESS"){
                
            	var qliResponse = response.getReturnValue();
                console.log(qliResponse);
                console.log(qliResponse.Quote);
                console.log(qliResponse.Quote.Opportunity);
                console.log(qliResponse.Quote.Opportunity.Account);
                
            	cmp.set("v.qliRecord",qliResponse);
                cmp.set("v.quoteRecord",qliResponse.Quote);
                cmp.set("v.opportunityRecord",qliResponse.Quote.Opportunity);
                cmp.set("v.accountRecord",qliResponse.Quote.Opportunity.Account);
            }
           
        });
        $A.enqueueAction(action);
    },
    
    
    fetchProjectTypePicklist : function(component){
        var action = component.get("c.getPicklistvalues");
        action.setParams({
            'objectName': 'Quote',
            'field_apiname': 'Project_TYpe__c',
            'nullRequired': true // includes --None--
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                component.set("v.projectTypeList", a.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    
    
    fetchQuoteTypePicklist : function(component){
        var action = component.get("c.getPicklistvalues");
        action.setParams({
            'objectName': 'Opportunity',
            'field_apiname': 'Quote_Type__c',
            'nullRequired': true
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                component.set("v.quoteTypeList", a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    validateConfiguration : function(cmp){
        var quote = cmp.get("v.quoteRecord");
        console.log(quote);
        console.log(cmp.get("v.quoteRecord"));
        console.log(cmp.get("v.opportunityRecord"));
        console.log(cmp.get("v.accountRecord"));
        
        var action = cmp.get("c.validateConfigurations");
        action.setParams({
            qli : cmp.get("v.qliRecord"),
            quoteRecord : cmp.get("v.quoteRecord"),
            opportunityRecord : cmp.get("v.opportunityRecord"),
            accountRecord : cmp.get("v.accountRecord"),
            validate : cmp.get("v.validate")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if(state === "SUCCESS"){
                
            	var qliResponse = response.getReturnValue();
                if(cmp.get("v.validate") == true ){
                    
                    var cmpqli = cmp.get("v.qliRecord");
        			if(cmpqli.Id){
        			var cmpdef = "c:LC01_CustomerScorings_";
        			cmpdef += (cmpqli.Location__c)?cmpqli.Location__c:"EU";
        			
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
        				"type": "Success",
        				"message": "Configuration Validated"
    				});
                        
    				toastEvent.fire(); 
        			var evt = $A.get("e.force:navigateToComponent");
        			evt.setParams({
            			componentDef : cmpdef,
            			componentAttributes: {
                			qliId : cmpqli.Id
            			}
        			});
        			evt.fire();
        			}
                }
                else{
                    
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
        				"type": "Success",
        				"message": "Configuration saved"
    				});
    				toastEvent.fire();
                    var urlEvent = $A.get("e.force:navigateToURL");
    				urlEvent.setParams({
      					"url": "/lightning/page/home"
    				});
    				urlEvent.fire();                    
                }
                
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                console.log('+++ERROR' + response.getError());
                       
				var message = 'Unknown Error'
                if (errors) {
                   if (errors[0] && errors[0].message) {
                            message =errors[0].message;
                   }
                }
                      
                var toastEvent = $A.get("e.force:showToast");
    			toastEvent.setParams({
        				"type": "Error",
        				"message": message
    			});
    			toastEvent.fire();  
            }
        });
        $A.enqueueAction(action);
        $A.util.removeClass(cmp.find("mySpinner3"), "slds-hide");
    }
    
})