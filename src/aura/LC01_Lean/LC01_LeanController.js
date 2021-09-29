({
	handleEvent : function(cmp, event, helper) {
        helper.openModal(cmp, event);
    },
    
    cancelchanges :  function(cmp, event, helper) {
    	cmp.find("vallean").set("v.value", ""); 
    	helper.closeModal(cmp, event);
    },
    
    savechanges :  function(cmp, event, helper) {
    	helper.closeModal(cmp, event);
    }
    
    
})