({
	    
	showSelected : function(cmp) {  
        
        var dynamicTableCmp = cmp.find("dynamicTableId");
        // Get the body and remove the last component inserted
        var body = dynamicTableCmp.get("v.body");
        console.log("body = "+body[0]);
        if (body.length > 0) {
            body.splice(0, 1);
        }        
        dynamicTableCmp.set("v.body", body);
        
		// Create the component, set the attributes and put it in the parent body        
        $A.createComponent(
            "c:QuoteWizardProductSelected",
            {
                "aura:id" : "tableId",
				"quoteLineItems" : cmp.get("v.quoteLineItemsSelected"),
                "currencies" : cmp.get("v.currencies"),
                "productCluster" : cmp.get("v.productCluster"),
                "productPlant" : cmp.get("v.productPlant"),
                "choosenCluster" : cmp.get("v.choosenCluster")
         	},
            function(newCmp){
                if (dynamicTableCmp.isValid()) {
                    var body = dynamicTableCmp.get("v.body");
                    body.push(newCmp);
                    console.log("body = "+body[0]);
                }
            }           
        );
    },
    
    displayMessage : function(cmp, errorMessage) {  
        // Added for brexit
        var modalElement = cmp.find('spinner');
        $A.util.addClass(modalElement,'slds-hide');

       	var errorMessageCmp = cmp.find("errorMessageId");
        // Get the body and remove the last component inserted
        var body = errorMessageCmp.get("v.body");
        console.log("body = "+body[0]);
        if (body.length > 0) {
            body.splice(0, 1);
        }
        console.log("body = "+body[0]);
        errorMessageCmp.set("v.body", body);
        
        $A.createComponent(
            "ui:outputText",
            {
                "value" : errorMessage
            },
            function(newCmp){
                if (errorMessageCmp.isValid()) {
                    var body = errorMessageCmp.get("v.body");
                    body.push(newCmp);
                    console.log("body = "+body[0]);
                }
            }           
        );
    }
})