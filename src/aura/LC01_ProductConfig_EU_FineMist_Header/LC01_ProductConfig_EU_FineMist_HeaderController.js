({
    init : function(cmp, event, helper) {
    
    	 cmp.find("Incoterm__c").set("v.value", "EXW");  
        
     
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

    
    <div class="slds-form--inline slds-p-horizontal--small">
        <div class="slds-form-element">
            <label class="slds-form-element__label" for="product_segment">Price : </label>            
            <ui:outputText value="Ex-Works / DDP France" />
        </div>
    </div>
*/