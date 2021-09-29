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