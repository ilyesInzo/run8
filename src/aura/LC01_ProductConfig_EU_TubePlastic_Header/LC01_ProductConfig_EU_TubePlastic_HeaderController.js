({
    init : function(cmp, event, helper) {
    	//COMBO
    	var optsCombo = [
	            { class: "optionClass", label: "No", value: "No" },
	            { class: "optionClass", label: "Yes", value: "Yes" }
	            
	     ];
	     cmp.find("Is_Combo__c").set("v.options", optsCombo);
	           
        //Payment Terms
        var optsPaymentTerms = [
            { class: "optionClass", label: "--None--", value: "" },
            { class: "optionClass", label: "Immediate", value: "Immediate" },
            { class: "optionClass", label: "30 days net", value: "30 days net"},
            { class: "optionClass", label: "45 days net", value: "45 days net"},
            { class: "optionClass", label: "60 days net", value: "60 days net"},
            { class: "optionClass", label: "75 days net", value: "75 days net"},
            { class: "optionClass", label: "90 days net", value: "90 days net"},
            { class: "optionClass", label: "120 days net", value: "120 days net" }
            
        ];
        cmp.find("Payment_terms__c").set("v.options", optsPaymentTerms);
        
        // Stockage
        var optsStockage = [
            { class: "optionClass", label: "--None--", value: ""},
            { class: "optionClass", label: "Make & Ship", value: "Make & Ship" },
            { class: "optionClass", label: "Up to 1 month", value: "Up to 1 month"},
            { class: "optionClass", label: "Up to 2 months", value: "Up to 2 months"},
            { class: "optionClass", label: "Up to 3 months", value: "Up to 3 months" }
        ];
        cmp.find("Stockage__c").set("v.options", optsStockage); 
       
    },
    handleOnClick : function(component, event, helper) {
    $A.util.toggleClass(component.find("divHelp"), 'slds-hide');
  },
  handleMouseLeave : function(component, event, helper) {
    $A.util.addClass(component.find("divHelp"), 'slds-hide');
  },
  handleMouseEnter : function(component, event, helper) {
    $A.util.removeClass(component.find("divHelp"), 'slds-hide');
  }, 
    displayDetailsJS: function(cmp, event, helper) {
        cmp.set("v.displayDetails", !cmp.get("v.displayDetails"));
        cmp.set("v.open2", !cmp.get("v.open2"));
        
        
    }, 

    hideDetailsJS : function(cmp, event, helper) {
        cmp.set("v.displayDetails", false);
        cmp.set("v.open2", false);
        
        
    }
    
})