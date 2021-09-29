({
	init : function(cmp, event, helper) {
        $(document).ready(function() {
            $('[data-aljs="popover"]').popover();
        });
	},
    
    itemchanged: function(cmp, event, helper){
		
    	//init on page load only once when qli has been queried and loaded
		if(cmp.get("v.qli").Id && event.getParam("value").Id && !event.getParam("oldValue").Id){
			cmp.set("v.score", cmp.get("v.qli").Customer_Scoring__c);
			var action = cmp.get("c.initscorings");
			action.setParams({
				qli : cmp.get("v.qli")
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
			
							 
			var action2 = cmp.get("c.getpicklistvalues");
			action2.setParams({
				scoringname : 'Customer',
				qli : cmp.get("v.qli")
			});
			action2.setCallback(this, function(actionResult2) {
				var state = actionResult2.getState();
				if (state === "SUCCESS") {        		
					var pickval = actionResult2.getReturnValue();
					cmp.set("v.mapoptions", pickval);
					
					var options = pickval["Customer_Type__c"];                 
					var opts=[];
					opts.push({"class": "optionClass", label: "--None--", value: ""});
					for(var i=0;i< options.length;i++){
						opts.push({"class": "optionClass", label: options[i], value: options[i]});
					}
					cmp.find("Customer_Type__c").set("v.options", opts);
					
					helper.validatescore(cmp, event, pickval);					
				} else {
						console.log('AN ERROR OCCURED' + state);
				}          
			});
			$A.enqueueAction(action2);
		}
		
		
    	//save changed item
        //show spinner
        // Lot 3 (Optimisation du scoring) -> Désactivation de l'update
       /* var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        helper.calculatescore(cmp, event);*/
        if(cmp.get("v.mapoptions")){
        	helper.validatescore(cmp, event, cmp.get("v.mapoptions"));
        }
    },
    
    hidespinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    resetscore: function(cmp, evt) {
    	var qli = cmp.get("v.qli");
    	qli.Customer_Type__c = "";
		qli.Business_at_other_product_line__c = "";
		qli.Payment_terms__c = "";
		qli.Required_level_of_documentation__c = "";
		qli.Monthly_overdue_DSO__c = "";
		qli.Quality_requirement__c = "";
		qli.Customer_end_of_year_rebate__c = "";
		qli.Customer_EBB_rate__c = "";
		qli.Additional_comments_on_customer_scoring__c = "";
    	
        var action = cmp.get("c.calculatescore");
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