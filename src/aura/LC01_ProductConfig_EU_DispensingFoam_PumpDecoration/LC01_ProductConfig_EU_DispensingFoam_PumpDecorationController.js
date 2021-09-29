({
	handleEvent : function(cmp, event, helper) {
    			        
	        if(event.getParam("name") == "Product_Hierarchy__c"){
	        	var label12 = (event.getParam("selectedValue") == "Dual Foamer")?"Holder Casing Coloring":"Cap coloring";
	        	cmp.set("v.label12", label12);
	        }
	        
	}
})