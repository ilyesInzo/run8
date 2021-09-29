({
	handleToggle : function(component, event, helper) {
        var compName  = component.get("v.name");
        var currentState = component.get("v.open");
        //console.log('############## handleToggle currentState: '+ compName +" : "+currentState);
        var nextState =  !currentState;
        console.log('############## handleToggle nextState: '+ compName +" : "+nextState);
        
        // 1- Close or Open section
        //var sectionHeader = event.currentTarget;
        component.set("v.open", nextState);
        
        // 2- Communicate that section will toggle (close/open)

		//var collapseEvent = $A.get("e.c:LE00_SectionAccordionCollapse");
		
        /*
         * RBE: disable for test (revert "open" attribute to false)
        var collapseEvent = component.getEvent("SectionCollapseEvent");
        collapseEvent.setParams({"name" : compName,"isOpen" : nextState });
		collapseEvent.fire();
        console.log('############## handleToggle fire CollapseEvent with params name : '+ compName + " isOpen: "+ nextState);
        */

	},
    savechanges :  function(cmp, event, helper) {
    
    
    /*
       if(cmp.get("v.selectedconfig").Id && !event.getParam("value").Id){
    	   console.log('*****section refreshed*****');
    	   	cmp.set("v.selectedconfig", cmp.get("v.selectedconfig"));	       
    	}*/ 
    
    	//if(cmp.get("v.selectedconfig").Id){    	
    	//check if object is not null and if the changed value is a field and not the object itself
    	/*
    	if(cmp.get("v.selectedconfig").Id && !event.getParam("value").Id){
	        var action = cmp.get("c.saveSelectedConfig");
	        action.setParams({
	            so : cmp.get("v.selectedconfig")
	        });
			action.setCallback(this, function(actionResult) {
	            var state = actionResult.getState();
	            if (state === "SUCCESS") {
	            	var config = actionResult.getReturnValue();
	            	console.log('*****SAVED*****' + actionResult.getReturnValue());
	            } else {
	                console.log('AN ERROR OCCURED saveSelectedConfig ' + state);
	            }        
	            
	            $A.get("e.c:LE00_SelectedTube").fire();
			});
			$A.enqueueAction(action); 
    	}*/
    }
   
})