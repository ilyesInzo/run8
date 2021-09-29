({
     
    doInit : function(cmp) {
		var action = cmp.get("c.getDataOnQuoteWizard");
        //console.log('ID=' + cmp.get("v.recordId"));
        action.setParams({
            quoteId : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
        	var _response = response.getReturnValue();
            
            cmp.set("v.displayContractReminder", _response.displayContractReminder);

            if (_response.displayAddProductButton == true) {
                console.log("DATA=", _response);
				console.log(_response.pricebooks);
            
            	cmp.set("v.displayAddProductButton", true);
                cmp.set("v.currencies", _response.currencies);
                cmp.set("v.defaultCurrency", _response.defaultCurrency);
                cmp.set("v.productCluster", _response.productCluster);
                cmp.set("v.productPlant", _response.productPlant);
                cmp.set("v.productFamilyItems", _response.productFamilyItems);            
                cmp.set("v.quoteLineItems", _response.quoteLineItems);
                cmp.set("v.priceBookEntriesMap", _response.priceBookEntriesMap);
                //               
                console.log('QUOTE LINE ITEMS..');
                console.log(_response.quoteLineItems);
                console.log('PRICE BOOK ENTIRES');
                console.log(_response.priceBookEntriesMap);
            } else {
                cmp.set("v.displayAddProductButton", false);
            } 
        });
        $A.enqueueAction(action);
        // Added for brexit
        cmp.set("v.countryCode",cmp.get("v.record.fields.Opportunity.value.fields.Account.value.fields.Country__r.value.fields.Country_Code__c.value"));

       
    },     
     displayProductLine : function(cmp, event, helper) {
         
         var selectedProductFamily = cmp.get("v.selectedProductFamily");
		 console.log('DISPLAY PRODUCT LINE...' + selectedProductFamily);  
         var priceBookEntriesMap = cmp.get("v.priceBookEntriesMap");  
         console.log(priceBookEntriesMap);
         console.log('PRICE BOOK ENTRIES FOUND....='+selectedProductFamily);
         cmp.set("v.priceBookEntries", priceBookEntriesMap[selectedProductFamily]);
         
         // MDK : TicketSUP_1524
         // Create the component with no QuoteLineItems
         helper.showSelected(cmp);	
         // End TicketSUP_1524
    },
    
	selectProductLine : function(cmp, event, helper) {
        var selectedRec = event.getSource().get("v.text");
        var selectedLine = "Line"+selectedRec;
        var selectedProductCheckboxValue = event.getSource().get("v.value");
        var newQuoteLineItems = cmp.get("v.quoteLineItems");
        // MDK : TicketSUP_1524
        var quoteLineItemsSelected = cmp.get("v.quoteLineItemsSelected");
        // End TicketSUP_1524
        if (selectedProductCheckboxValue) {
            console.log(selectedLine);
            console.log(cmp.find(selectedLine));
            for (var i=0; i <newQuoteLineItems.length; i++) {
                if (newQuoteLineItems[i].PricebookEntryId == selectedRec) {
                    newQuoteLineItems[i].Stamp__c  = 'Selected';
                    // MDK : TicketSUP_1524
                    quoteLineItemsSelected.push(newQuoteLineItems[i]);
        			// End TicketSUP_1524                    
                } 
            }            
        } else {
            for (var i=0; i <newQuoteLineItems.length; i++) {
            	if (newQuoteLineItems[i].PricebookEntryId == selectedRec) {
            		newQuoteLineItems[i].Stamp__c  = '';
                    // MDK : TicketSUP_1524
                    var index = quoteLineItemsSelected.indexOf(newQuoteLineItems[i]);
                    if (index !== -1) {
                        quoteLineItemsSelected.splice(index, 1);
                    }
                    // End TicketSUP_1524
            	}   
            }         
            
        }
        // MDK : TicketSUP_1524
        cmp.set("v.quoteLineItemsSelected",quoteLineItemsSelected);
        helper.showSelected(cmp);
        //helper.displayMessage(cmp, "");
        // End TicketSUP_1524
        
        console.log('CHECKED=' + selectedProductCheckboxValue);

    },

	saveQuoteItem : function(cmp, event, helper) {
         // Added for brexit
         cmp.set("v.displayBrexitPopup", false);
         var modalElement = cmp.find('spinner');
         $A.util.removeClass(modalElement,'slds-hide');
         // end Brexit
         var newQuoteLineItems = cmp.get("v.quoteLineItems");
		 console.log('SAVING PRODUCT LINE...'); 
         console.log(newQuoteLineItems); 
        
        // MDK : TicketSUP_1524
        // Trace for debug
		var quoteLineItemsSelected = cmp.get("v.quoteLineItems");
        for (var i=0; i <quoteLineItemsSelected.length; i++) {
            if (quoteLineItemsSelected[i].Stamp__c == 'Selected') {
                console.log("Line Items Selected = "+quoteLineItemsSelected[i].PricebookEntryId+" Quantity = "+newQuoteLineItems[i].Quantity);
            }
        }
        // End TicketSUP_1524
        
		var validate = true;
        for (var i=0; i <newQuoteLineItems.length; i++) {
            //console.log(newQuoteLineItems[i]);
            if (newQuoteLineItems[i].Stamp__c == 'Selected' && 
                (newQuoteLineItems[i].Quantity == '' || newQuoteLineItems[i].Quantity == '0')) {
                //console.log(newQuoteLineItems[i].Quantity);
                newQuoteLineItems[i].Description__c = 'Quantity is Mandatory.';
                helper.displayMessage(cmp,"Quantity is Mandatory.");
                validate = false;
            }
            
        }
        
        if (validate) {
            var action = cmp.get("c.saveQuoteItems");
            //console.log('ID=' + cmp.get("v.recordId"));
            action.setParams({
                jsonQuoteLineItem : JSON.stringify(newQuoteLineItems),
                quoteId : cmp.get("v.recordId"),
                defaultCurrency : cmp.get("v.defaultCurrency"),
                priceBookId : cmp.get("v.selectedPriceBook")
            }); 
            console.log(action); 
            action.setCallback(this, function(response) {
                var _response = response.getReturnValue();
                console.log("DATA=", _response);
                if (_response == 'SUCCESS') {                    
                   	cmp.closeModalMethod();
                   	// MDK : TicketSUP_1524 
                   	cmp.find("dynamicTableId").set("v.body", []);
                    cmp.find("errorMessageId").set("v.body", []);
                    cmp.set("v.priceBookEntries", null);  
        			cmp.set("v.selectedProductFamily", null);
                    cmp.set("v.productFamilyItems", null);
                    cmp.set("v.quoteLineItemsSelected", []);
					// End TicketSUP_1524					                    
                   $A.get('e.force:refreshView').fire();
                } else {
                    // MDK : TicketSUP_1524
                    helper.displayMessage(cmp, _response);
                    // End TicketSUP_1524
                    console.log('ERROR OCCURED');
                }
                 
            });
            $A.enqueueAction(action);       
    	}
        
    },    
    showModal : function(component, event, helper) {
        
    	console.log('Showing modal..2');
        //console.log('Showing modal..'+document.getElementById("yourId"));
        console.log(component.find('productModal'));
        var modalElement = component.find('productModal');
		$A.util.removeClass(modalElement,'slds-fade-in-hide');
    	$A.util.addClass(modalElement,'slds-fade-in-open');
        
       

		component.refreshMethod();
        //$A.get('e.force:refreshView').fire();
        //document.getElementById("yourId").style.display = "block";
     
    }, 
    
    hideModal : function(component,event, helper){
    	
    	console.log('Hiding modal..2');
        //console.log('Hiding modal..'+document.getElementById("yourId"));    
        console.log(component.find('productModal'));
        var modalElement = component.find('productModal');
		$A.util.removeClass(modalElement,'slds-fade-in-open');
    	$A.util.addClass(modalElement,'slds-fade-in-hide'); 
        
        //component.set("v.currencies", null);
        //component.set("v.defaultCurrency", null);
        component.set("v.productFamilyItems", null);            
        //component.set("v.quoteLineItems", null);
        component.set("v.priceBookEntries", null);  
        component.set("v.selectedProductFamily", null);
        //component.set("v.priceBookEntriesMap", null); 
        //$A.get('e.force:refreshView').fire();
       	//document.getElementById("yourId").style.display = "none" ;
       	// MDK : TicketSUP_1524
        component.set("v.quoteLineItemsSelected", []);
        component.find("dynamicTableId").set("v.body", []);
        component.find("errorMessageId").set("v.body", []);
		// End TicketSUP_1524        

   },

   
    recordUpdated : function(component, event, helper) {

        var changeType = event.getParams().changeType;

        if (changeType === "ERROR") {}
        else if (changeType === "LOADED") {}
        else if (changeType === "REMOVED") {}
        else if (changeType === "CHANGED") { 
            var status = component.get("v.record.fields.Status.value");
            if(status == "Won" || status == "Killed By Albea" || status == "Lost" || status == "Killed By Customer" || status == "Presented"){
                component.set("v.displayAddProductButton", false);
            }
            else{
                component.set("v.displayAddProductButton", true);
            }
        }
    }, 

    // Added for brexit
    displayBrexitPopupJS : function(component, event, helper) {
        
        component.set("v.displayBrexitPopup", true);
        modalElement = component.find('brexitModal');
        $A.util.removeClass(modalElement,'slds-fade-in-hide');
        $A.util.addClass(modalElement,'slds-fade-in-open');
    }

})