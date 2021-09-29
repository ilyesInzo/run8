({
    timedRefresh : function(component, event, helper) { 
        
        //execute Refresh() after 20 sec 

        window.setTimeout(
    $A.getCallback(function() {
        helper.refreshMethod(component,helper)}), 20000);
    },

    refreshMethod : function (component,helper){    
        console.log("Helper One");
        $A.get('e.force:refreshView').fire();
        
    } 
})