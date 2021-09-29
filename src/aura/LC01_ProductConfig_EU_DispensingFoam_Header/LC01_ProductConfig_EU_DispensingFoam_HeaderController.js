({
    init : function(cmp, event, helper) {
    
    /*	var opts=[];
        opts.push({"class": "optionClass", label: "FCA Alkmaar", value: "FCA Alkmaar"});        
        opts.push({"class": "optionClass", label: "EXW", value: "EXW"});
        opts.push({"class": "optionClass", label: "Delivered", value: "Delivered"});        
        cmp.find("Incoterm__c").set("v.options", opts);
      */
      cmp.find("Incoterm__c").set("v.value", "FCA Alkmaar");  
     
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

/*
  <div class="slds-p-horizontal--small slds-size--1-of-1 slds-medium-size--1-of-3 slds-large-size--1-of-3">
            <label class="slds-form-element__label" >Price  </label>            
            <div class="slds-form-element__control">
            	<ui:outputText value="FCA Alkmaar"  />
            </div>
        </div>

*/