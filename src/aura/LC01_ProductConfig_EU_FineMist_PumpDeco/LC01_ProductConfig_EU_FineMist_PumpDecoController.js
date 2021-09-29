({
	
	handleEvent : function(cmp, event, helper) {
	        var fName = event.getParam("name");
	        var selectedValue = event.getParam("selectedValue");
	        if(fName == 'Cap_Type__c'){
	        	if(selectedValue == 'Tricorner cap (Trade)' || selectedValue == 'Cylindrical cap (Trade)'){	        	
	        		cmp.set("v.capfinishcond1", true);      	
	        		cmp.set("v.capfinishcond2", false);
	        	}
	        	else{
	        		cmp.set("v.capfinishcond1", false);      	
	        		cmp.set("v.capfinishcond2", true);
	        	}
	        }
	        
	 }
})