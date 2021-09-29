({
	init : function(cmp, event, helper) {
        console.log('Deal Scoring IN');	
        $(document).ready(function() {
            $('[data-aljs="popover"]').popover();
        });
	},
    
    itemchanged: function(cmp, event, helper){
			
    	//init on page load only once when qli has been queried and loaded
    	if(event.getParam("value") !== null){
			if(cmp.get("v.qli").Id && event.getParam("value").Id && !event.getParam("oldValue").Id){
				var productline = "";
				productline = (cmp.get("v.qli").Product_Line__c == 'Tubes')?'Tubes__c':productline;
				productline = (cmp.get("v.qli").Product_Line__c == 'Dispensing')?'Dispensing__c':productline;			
								
				var action2 = cmp.get("c.getpicklistvalues");
				action2.setParams({
					scoringname : 'Deal',
					qli : cmp.get("v.qli")
				});
				action2.setCallback(this, function(actionResult2) {
					var state = actionResult2.getState();
					if (state === "SUCCESS") {        		
						var pickval = actionResult2.getReturnValue();
						cmp.set("v.mapoptions", pickval);
						
						helper.validatescore(cmp, event, pickval);
					} else {
							console.log('AN ERROR OCCURED' + state);
					}          
				});
				$A.enqueueAction(action2);
	        }
		}
		
    	//save changed item
        //show spinner
         // Lot 3 (Optimisation du scoring) -> Désactivation de l'update
       /* var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        helper.calculatedealscore(cmp, event);*/
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
		/*qli.Quote.Brand_Positionning__c = "";
		qli.Quote.of_month_of_stock_at_Alb_a_expenses__c = "";
		qli.Quote.Contract_duration__c = "";
		qli.Quote.Indexation_of_raw_material_costs__c = "";
		qli.Quote.Exclusivity_Single_vs_Multiple_Supplier__c = "";
		qli.Quote.Tooling_CAPEX_investments_required__c = "";
		qli.Quote.Alb_a_dependency_to_supplier_s__c = "";
		qli.Quote.Penalties_for_the_customer_in_the_contra__c = "";
		qli.Quote.Type_of_business__c = "";
		qli.Quote.Penalties_in_the_contract_for_Alb_a__c = "";
		qli.Quote.Multiple_Release_Order_Blanket_Order__c = "";
		qli.Quote.Skonto_for_cash_payment__c = "";
		qli.Quote.Additionnal_comments_on_deal_scoring__c = "";
		qli.Quote.Tooling_CAPEX_investment_required__c = null;*/
		
		 //HM 20170521 - Deal Scoring is now in Quote Item
		qli.Brand_Positionning__c = "";
		qli.DS_NB_month_of_stock_at_Albea_expenses__c = "";
		qli.DS_Contract_duration__c = "";
		qli.DS_Indexation_of_raw_material_costs__c = "";
		qli.DS_Exclusivity_Single_vs_Multiple_Supp__c = "";
		qli.DS_Tooling_CAPEX_investments_required__c = "";
		qli.DS_Albea_dependency_to_suppliers__c = "";
		qli.DS_Penalties_customer_in_the_contract__c = "";
		qli.DS_Type_of_business__c = "";
		qli.DS_Penalties_in_the_contract_for_Albea__c = "";
		qli.DS_Multiple_Release_Order_Blanket_Order__c = "";
		qli.DS_Skonto_for_cash_payment__c = "";
		qli.DS_Additionnal_comments_on_deal_scoring__c = "";
		qli.DS_Tooling_CAPEX_investment_required__c = null;		
		
		
		
		var action = cmp.get("c.calculatedealscore");
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