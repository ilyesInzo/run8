({
    init : function(component, event, helper) {
    	var sObjectName = component.get("v.sObjectName");
        var recordId = component.get("v.recordId");
        
        if(sObjectName == 'Opportunity'){
            component.set("v.oppId",recordId);
        }
        
        console.log('AAAA :' + component.get("v.oppId") );
        console.log('BBBB :' + component.get("v.qliId") );
    
    },
    
    hideSpinner : function(cmp, event, helper) {
         $A.util.addClass(cmp.find("mySpinner3"), "slds-hide");
    }, 
    
    validateConfiguration : function(component, event, helper) {
        //Dynamic creation of lightningModalChild component and appending its markup in a div
        var qliId = component.get("v.qliId");
        
		$A.createComponent( 'c:LC01_ValidateQuote', {
                qliId : component.get("v.qliId") ,
            	oppId : component.get("v.oppId"),
            	validate : true
            },
            function(modalComponent, status, errorMessage) {
                if (status === "SUCCESS") {
                    //Appending the newly created component in div
                    var body = component.find( 'showChildModal' ).get("v.body");
                    body.push(modalComponent);
                    component.find( 'showChildModal' ).set("v.body", body);
                } else if (status === "INCOMPLETE") {
                	console.log('Server issue or client is offline.');
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
        				"type": "Error",
        				"message": "Server issue or client is offline."
    				});
    				toastEvent.fire();
                } else if (status === "ERROR") {
                	console.log('error');
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
        				"type": "Error",
        				"message": "Uncknown Error."
    				});
    				toastEvent.fire();
                }
            }
        );
	},
    
    saveConfiguration: function(component, event, helper) {
        //Dynamic creation of lightningModalChild component and appending its markup in a div
        var qliId = component.get("v.qliId");
		$A.createComponent( 'c:LC01_ValidateQuote', {
                qliId : component.get("v.qliId"),
            	oppId : component.get("v.oppId"),
            	validate : false
            },
            function(modalComponent, status, errorMessage) {
                if (status === "SUCCESS") {
                    //Appending the newly created component in div
                    var body = component.find( 'showChildModal' ).get("v.body");
                    body.push(modalComponent);
                    component.find( 'showChildModal' ).set("v.body", body);
                } else if (status === "INCOMPLETE") {
                	console.log('Server issue or client is offline.');
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
        				"type": "Error",
        				"message": "Server issue or client is offline."
    				});
    				toastEvent.fire();
                } else if (status === "ERROR") {
                	console.log('error');
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
        				"type": "Error",
        				"message": "Uncknown Error."
    				});
    				toastEvent.fire();
                    
                }
            }
        );
    },
    
    deleteConfiguration: function(component, event, helper) {
        var qliId = component.get("v.qliId");
        var oppId = component.get("v.oppId");
        var result = confirm("Want to delete?");
        if (result) {
            var action = component.get("c.deleteConfigurations");
        	action.setParams({
            	qliId : qliId,
                oppId : oppId
        	});
        	
            action.setCallback(this, function(response) {
            	var state = response.getState();
            	if(state === "SUCCESS"){
                	console.log("------ Q L I SUCCESS ------");
                	//var result = response.getReturnValue();
                    
                    console.log("Record is deleted.");
                    
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
        				"type": "Success",
        				"message": "The Simulation Record has been Deleted successfully."
    				});
    				toastEvent.fire();
                	
                    var redirect = $A.get("e.force:navigateToURL");
                	redirect.setParams({
                    	"url": "/lightning/page/home"
                	});

                	redirect.fire();
            	}
            	else if(state === 'ERROR'){               
                	
                   	console.log("------ Q L I ERROR ------");
                	var errors = response.getError();
                    console.log('+++ERROR' + response.getError());
                       
					var message = 'Unknown Error'
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            message =errors[0].message;
                        }
                    }
                      
                    var toastEvent = $A.get("e.force:showToast");
    				toastEvent.setParams({
        				"type": "Error",
        				"message": message
    				});
    				toastEvent.fire(); 
                         
            	}    
        	});
        	$A.enqueueAction(action);
            $A.util.removeClass(component.find("mySpinner3"), "slds-hide");
        }
       
    },
    
})