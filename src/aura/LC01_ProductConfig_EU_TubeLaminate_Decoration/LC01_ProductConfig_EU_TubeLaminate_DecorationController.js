({
	 handleEvent : function(cmp, event, helper) {
        
        var fName = event.getParam("name");
        var selectedValue = event.getParam("selectedValue");
        
        if(fName == "Cap_Eurocode__c"){
            var printtechno = (selectedValue || selectedValue != '')?'Flexo':'';
            cmp.find("printtechno").set("v.value",printtechno);
        }
      
        
        
	}
})