({
    init : function(cmp, event, helper) {
        
		if(cmp.get("v.qli").Id && event.getParam("value").Id && !event.getParam("oldValue").Id){
        // fixed image
        //helper.fixProductImage(cmp);
        
        var action = cmp.get("c.getSelectedConfig");
        var qli = cmp.get("v.qli");
        var mapfilters = {
        'Quote_item__c' : qli.Id,
        'Product_Segment__c' : qli.Product_Sub_segment__c,
            //'Purefoil_Segment__c' : qli.Purefoil_Segment__c , // FIXME: RBE: Adapte Query to manage boolean instead of text fields
        'Location__c' : qli.Location__c,
        //'Payment_terms__c':qli.Payment_terms__c // Adapt Query to get the right selected_Tube_config to display the Platts Value
        }     
        console.log( ' map filter '+ JSON.stringify( mapfilters ))
        action.setParams({
        	so : cmp.get("v.selectedtubeconfig"),
            mapfilters : mapfilters
        });
        action.setCallback(this, function(response) {
        	console.log("selectedtubeconfig", response.getReturnValue());
        	var _config = response.getReturnValue();
        	_config['sobjectType'] = 'PM_Selected_Tubes_Config__c';
        	cmp.set("v.selectedtubeconfig", response.getReturnValue());
        	cmp.set("v.selectedtubeconfig.Payment_terms__c",cmp.get("v.qli").Payment_terms__c)
            console.log(' Platts Test '+ _config.Nouveau_Platts__c )     	
        });
        $A.enqueueAction(action);
        }
    },
    handleCollapseEvent : function(component, event, helper) {
        // 1- Get Collapse Event params
        var fromSectionName = event.getParam("name"); 
        var newStateFromOtherSection = event.getParam("isOpen"); //component.get("v.isOpen");
        console.log('############## Event received from Section: '+fromSectionName+" new state: "+newStateFromOtherSection);
        // 2- update collapseStatus
         
        var collapseStatus = component.get("v.collapseStatus");
        for (var k in collapseStatus){
            if (newStateFromOtherSection === true && k != fromSectionName.split(' ').join('_')) {
                collapseStatus[k] = false;
            }
        }
        component.set("v.collapseStatus", collapseStatus);
    },
    
    OpenImageInModal : function(component, event, helper) {
        
        var target = event.currentTarget;
		var badgeName = target.dataset.record;
        
        $A.createComponent( 'c:LC00_ShowImage', {
            	title : 'Green Friday Campaign',
            	imageName : 'GreenFridayLamEU',
            	imageFormat : 'png'
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
        
    }
})