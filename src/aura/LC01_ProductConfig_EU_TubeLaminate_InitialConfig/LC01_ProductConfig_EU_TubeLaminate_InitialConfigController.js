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
            { class: "optionClass", label: "30 days", value: "30 days"},
            { class: "optionClass", label: "45 days", value: "45 days"},
            { class: "optionClass", label: "60 days", value: "60 days"},
            { class: "optionClass", label: "75 days", value: "75 days"},
            { class: "optionClass", label: "90 days", value: "90 days"},
            { class: "optionClass", label: "120 days", value: "120 days" }
            
        ];
        cmp.find("Payment_terms__c").set("v.options", optsPaymentTerms);
        cmp.find("Payment_terms__c").set("v.value", cmp.get('v.qli.Payment_terms__c'));
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
     SelectChange: function(cmp) {
		 var comboCmp = cmp.find("Is_Combo__c").get("v.value");
         //console.log("Combo is "+comboCmp);
		 
		if(comboCmp =="No")
        {cmp.find("Combo_Num_Versions__c").set("v.value",  null);
         cmp.find("Combo_Num_Plate_Changes__c").set("v.value",  null);
         cmp.find("Combo_Num_Tubes_Artwork__c").set("v.value",  null);
        }
	 }
})