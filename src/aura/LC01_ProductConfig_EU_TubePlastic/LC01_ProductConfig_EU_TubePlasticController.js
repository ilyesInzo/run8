({
    init : function(cmp, event, helper) {
        
              if(cmp.get("v.qli").Id && event.getParam("value").Id && !event.getParam("oldValue").Id){
            // fixed image
            //helper.fixProductImage(cmp);
            
            var action = cmp.get("c.getSelectedConfig");
            var qli = cmp.get("v.qli");
                  console.log("qli first "+ qli);
                  /**Initialise LAst Qli if it is already done
                  if(qli.last_QLI_Payment_term__c!=null && qli.last_QLI_Payment_term__c==qli.Payment_terms__c)
                  {
                      qli.last_QLI_Payment_term__c==null;
                  } */
            var mapfilters = {
            'Quote_item__c' : qli.Id,
            'Product_Segment__c' : qli.Product_Sub_segment__c,
                //'Purefoil_Segment__c' : qli.Purefoil_Segment__c , // FIXME: RBE: Adapte Query to manage boolean instead of text fields
            'Location__c' : qli.Location__c,
            //'Payment_terms__c':qli.Payment_terms__c//(qli.last_QLI_Payment_term__c!=null)?qli.last_QLI_Payment_term__c:qli.Payment_terms__c
            }        
            action.setParams({
                so : cmp.get("v.selectedtubeconfig"),
                mapfilters : mapfilters
            });
            action.setCallback(this, function(response) {
                console.log("selectedtubeconfig", response.getReturnValue());
                var _config = response.getReturnValue();
                _config['sobjectType'] = 'PM_Selected_Tubes_Config__c';
                cmp.set("v.selectedtubeconfig", response.getReturnValue());
                console.log("payment OUT", cmp.get("v.selectedtubeconfig.Payment_terms__c")+'/'+qli.Payment_terms__c);        
               cmp.set("v.selectedtubeconfig.Payment_terms__c",cmp.get("v.qli").Payment_terms__c)
        
              console.log("payment after", cmp.get("v.selectedtubeconfig.Payment_terms__c")+'/'+cmp.get("v.qli").Payment_terms__c);        
          
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
    updateConfig: function(component, event, helper) {

         var selectedConfig = event.getParam("selectedConfig");
        component.set("v.selectedtubeconfig", selectedConfig);
        
    }
})