({	
    handleEvent : function(cmp, event, helper) {
        
        var fName = event.getParam("name");
        var selectedValue = event.getParam("selectedValue");
        
        if(fName == "Dispensing_System_Name__c"){
            var hname = cmp.find("headname");
            hname.set("v.value",selectedValue);
        }
        
        
	}
})