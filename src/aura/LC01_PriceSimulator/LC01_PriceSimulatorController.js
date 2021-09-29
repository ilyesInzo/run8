({
    
     init: function(cmp, event, helper) {
         helper.fetchMarketOfApplication(cmp);
     },
    
    hideSpinner : function(cmp, event, helper) {
         $A.util.addClass(cmp.find("mySpinner3"), "slds-hide");
     },
    
     openProductConfigPage: function(cmp, event, helper) {
         var productSubSegment = cmp.get("v.selectedSubProduct");
		console.log("MarketOfApplication"+ cmp.get("v.marketOfApplication"));
		console.log("product"+ cmp.get("v.selectedSubProduct"));
        console.log("Opportunity"+ cmp.get("v.opportunityName"));
        console.log("annual"+ cmp.get("v.annualQuantity"));
        console.log("Account"+ cmp.get("v.accountName"));
           
         if(cmp.get("v.selectedSubProduct") == undefined || cmp.get("v.selectedSubProduct") == null || cmp.get("v.selectedSubProduct") == '--None--' ||
            cmp.get("v.marketOfApplication") == undefined || cmp.get("v.marketOfApplication") == null || cmp.get("v.marketOfApplication") == '--None--' ||
            cmp.get("v.opportunityName") == undefined || cmp.get("v.opportunityName") == null ||
            cmp.get("v.annualQuantity") == undefined || cmp.get("v.annualQuantity") == null ||
            cmp.get("v.accountName") == undefined || cmp.get("v.accountName") == null){
              var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                                          message: 'Fields Missed' ,
                                          type : "error"
                                            });
                    toastEvent.fire();
         }
         else{
             helper.openProductConfigPage(cmp);
         }
         
    },

    accountChange : function(cmp, event, helper){
        
        var accountRecord = cmp.get("v.accountName");

        if(accountRecord.Name == null || accountRecord.Name == undefined ){
            
            cmp.set("v.subProducts", "");
            cmp.set("v.selectedSubProduct", "None");
            
        }
                
        else{
            var action = cmp.get("c.getElligibleProduct");
        
            action.setParams({
                
                "accountId"  : cmp.get("v.accountName.Id") , 
                
            });
            
            action.setCallback(this, function(response){
                var state = response.getState();
                if (cmp.isValid() && state === "SUCCESS") {

                    var result = response.getReturnValue();
                    
                    cmp.set("v.subProducts", result);
                }
                else if (state === "ERROR"){
                    var errors = response.getError();
                    console.log('+++ERROR' + response.getError());
                       
                    cmp.set("v.subProducts", "");
                    cmp.set("v.selectedSubProduct", "None");
					var message = 'Unknown Error'
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            message =errors[0].message;
                        }
                    }
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                                          message: message ,
                                          type : "error"
                                            });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }

            });
            $A.enqueueAction(action);
        }

    },
    
})