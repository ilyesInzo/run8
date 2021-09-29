({
	init : function(cmp, event, helper) {
        $(document).ready(function() {
            $('[data-aljs="popover"]').popover();
        });
	},
    
    itemchanged: function(cmp, event, helper){
		
    	//init on page load only once when qli has been queried and loaded
		if(cmp.get("v.qli").Id && event.getParam("value").Id && !event.getParam("oldValue").Id){
		
			var action2 = cmp.get("c.getpicklistvalues");
			action2.setParams({
				scoringname : 'Service',
				qli : cmp.get("v.qli")
			});
			action2.setCallback(this, function(actionResult2) {
				var state = actionResult2.getState();
				if (state === "SUCCESS") {        		
					var pickval = actionResult2.getReturnValue();
					cmp.set("v.mapoptions", pickval);					
				} else {
						console.log('AN ERROR OCCURED' + state);
				}          
			});
			$A.enqueueAction(action2);
        }
        
    	//save changed item
        //show spinner
        // Lot 3 (Optimisation du scoring) -> Désactivation de l'update
        /*var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        helper.calculateservicescore(cmp, event);*/
    },
    
    hidespinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    resetscore: function(cmp, evt) {
    	var qli = cmp.get("v.qli");
		
		qli.Sampling__c = "Not Applicable";
		qli.Below_MOQs__c = "Not Applicable";
		qli.Decoration_development__c = "Not Applicable";
		qli.Product_Customization__c = "Not Applicable";
		qli.Color_matching_process__c = "Not Applicable";
		qli.Non_standard_supply_chain_process__c = "Not Applicable";
		qli.Preproduction__c = "Not Applicable";
		qli.Regulatory_Affairs__c = "Not Applicable";
		qli.Compatibility_Tests__c = "Not Applicable";
		qli.R_D_Office__c = "Not Applicable";
		qli.Spray_Tests__c = "Not Applicable";
		qli.Training_for_customer__c = "Not Applicable";
		qli.Additionnal_comments_on_service_scoring__c = "";
				
		var action = cmp.get("c.calculateservicescore");
        action.setParams({
            qli : qli
        });
		action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
        		cmp.set("v.qli", actionResult.getReturnValue());        		
            } else {
	                console.log('AN ERROR OCCURED' + state);
            }          
		});
		$A.enqueueAction(action);
    }
})