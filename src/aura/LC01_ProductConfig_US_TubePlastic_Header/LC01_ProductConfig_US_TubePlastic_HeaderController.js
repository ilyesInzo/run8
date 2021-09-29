({
    init : function(cmp, event, helper) {
    
    /*	var opts=[];
        opts.push({"class": "optionClass", label: "--None--", value: ""});
        opts.push({"class": "optionClass", label: "EXW", value: "EXW"});
        opts.push({"class": "optionClass", label: "Delivered", value: "Delivered"});        
        cmp.find("Incoterm__c").set("v.options", opts);
      */
      
    	 //COMBO
    	var optsCombo = [
	            { class: "optionClass", label: "No", value: "No" },
	            { class: "optionClass", label: "Yes", value: "Yes" }
	            
	     ];
	     cmp.find("Is_Combo__c").set("v.options", optsCombo);
      
    	cmp.find("Incoterm__c").set("v.value", "EXW");  
        
        var opts2=[];
        opts2.push({"class": "optionClass", label: "--None--", value: ""});
        opts2.push({"class": "optionClass", label: "1- Standard QIS", value: "1- Standard QIS"});
        opts2.push({"class": "optionClass", label: "2 - Hightened Quality Requirement", value: "2 - Hightened Quality Requirement"});
        opts2.push({"class": "optionClass", label: "3 - Zero Defects", value: "3 - Zero Defects"});
        opts2.push({"class": "optionClass", label: "4 - Customer Specific", value: "4 - Customer Specific"});       
        cmp.find("Quality_Level__c").set("v.options", opts2);
        
       
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