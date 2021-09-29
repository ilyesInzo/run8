({
    init : function(cmp, event, helper) {
     
        var action = cmp.get("c.validlinkforcebutton");
        action.setParams({
        	quoteItemId : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
        	cmp.set("v.linkforcebutton", response.getReturnValue());
        	        	
        });
        $A.enqueueAction(action);
    },
    showModal : function(component, event, helper) {
    	console.log('Showing modal..2');
        //console.log('Showing modal..'+document.getElementById("yourId"));
        console.log(component.find('zephyrModal'));
        var modalElement = component.find('zephyrModal');
		$A.util.removeClass(modalElement,'slds-fade-in-hide');
    	$A.util.addClass(modalElement,'slds-fade-in-open');        
        
        //document.getElementById("yourId").style.display = "block";
     
    }, 
    
    hideModal : function(component,event, helper){
    	console.log('Hiding modal..2');
        //console.log('Hiding modal..'+document.getElementById("yourId"));    
        console.log(component.find('zephyrModal'));
        var modalElement = component.find('zephyrModal');
		$A.util.removeClass(modalElement,'slds-fade-in-open');
    	$A.util.addClass(modalElement,'slds-fade-in-hide'); 
       //document.getElementById("yourId").style.display = "none" ;
   },
    
    
   ClickReadData : function(component, event, helper) {
        
        var dataInput = component.get("v.ZephyrInput");
        var inputField = component.find("Input");
     	
        if ($A.util.isEmpty(dataInput)){
	            
	        inputField.set("v.errors", [{message:"Input Data cannot be blank."}]);
	    }else {
	        var modalElement = component.find('zephyrModal');
            inputField.set("v.errors", null);
            console.log(dataInput);
            console.log(component.get("v.recordId"));
            helper.ReadData(component, dataInput);

            $A.util.removeClass(modalElement,'slds-fade-in-open');
    		$A.util.addClass(modalElement,'slds-fade-in-hide');
            
	    }   
    }
})