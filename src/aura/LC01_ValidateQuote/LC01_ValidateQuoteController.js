({
	init : function(cmp, event, helper) {
        // Get Quote
        console.log("LC01_ValidateQuoteController:JsController:Init ");
        
        if(cmp.get("v.validate") == true){
        	cmp.set("v.headerText","Validate Configuration")    
        }
        else{
        	cmp.set("v.headerText","Save Configuration")        
        }
        
        helper.fetchProjectTypePicklist(cmp); // fetches PickList Values of Project Type Field
        helper.fetchQuoteTypePicklist(cmp); // fetches PickList Values of Quote type Field
        helper.initiateObjects(cmp); // initiate Opportunity , Quote and Account Fields    
       
    },
    
    hideSpinner : function(cmp, event, helper) {
         $A.util.addClass(cmp.find("mySpinner3"), "slds-hide");
     },
    
    closeModal : function(cmp, event, helper) {
        console.log("LC01_ValidateQuoteController:JsController:closeModal ");
    	cmp.destroy();
	},
    
    validateConfiguration : function(cmp, event, helper) {
    	console.log("LC01_ValidateQuoteController:JsController:validateConfiguration ");
        console.log('quote1' + cmp.get("v.quoteRecord"));
        console.log('opportunity1' + cmp.get("v.opportunityRecord"));
        console.log('account1' + cmp.get("v.accountRecord"));
        helper.validateConfiguration(cmp);
	},
  	
    saveConfiguration : function(cmp, event, helper) {
        console.log("LC01_ValidateQuoteController:JsController:saveConfiguration ");
        helper.validateConfiguration(cmp);
	}
})