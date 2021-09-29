({
	ReadData: function(component, dataInput) {
        var action = component.get("c.readZephyrData");
        var modalElement = component.find('messageModal');
        action.setParams({
            "zephyrDataInput": dataInput,
            "quoteId":component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
               


                $A.get('e.force:refreshView').fire();
                var rtnMss = response.getReturnValue();
                if((rtnMss === $A.get('$Label.c.Linkforce_Error_Message')) 
                    || rtnMss === $A.get('$Label.c.Linkforce_Too_Short_Message')){
                    alert(rtnMss);
                    // $A.util.removeClass(modalElement,'slds-fade-in-open');
                    // $A.util.addClass(modalElement,'slds-fade-in-hide');
                }
                else{
                    $A.util.removeClass(modalElement,'slds-fade-in-hide');
                    $A.util.addClass(modalElement,'slds-fade-in-open');
                    setTimeout(function(){
                        $A.util.removeClass(modalElement,'slds-fade-in-open');
                        $A.util.addClass(modalElement,'slds-fade-in-hide');
                    }, 3000);
                }
                component.set("v.ZephyrInput", '');
             	

                setTimeout(function(){
                    $A.util.removeClass(modalElement,'slds-fade-in-open');
                    $A.util.addClass(modalElement,'slds-fade-in-hide');
                }, 3000);
            }
        });
        $A.enqueueAction(action);
	}
    
})