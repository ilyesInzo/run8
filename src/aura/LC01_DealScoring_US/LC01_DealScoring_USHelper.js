({
    calculatedealscore: function(cmp, evt) {
    
      var isafield = false;
      if(evt.getParam("value") === null){
    	  isafield = true;
    	  console.log('is null');
      }
      else{
    	  isafield = (evt.getParam("value").Id)?false:true;
    	  isafield = (evt.getParam("oldValue") === undefined && evt.getParam("value") === "")?false:isafield;
    	  isafield = (evt.getParam("value").Id && isNaN(cmp.get("v.qli").Deal_Scoring__c))?true:isafield;
      }
      //check if object is not null and if the changed value is a field and not the object itself
      if(cmp.get("v.qli").Id && isafield){
        var action = cmp.get("c.calculatedealscore");
        action.setParams({
            qli : cmp.get("v.qli")           
        });
		action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
        		cmp.set("v.qli", actionResult.getReturnValue());        		
				console.log('Deal Scoring SAVE Success');	
            } else {
	                console.log('AN ERROR OCCURED' + state);
                  if(actionResult.getError()[0].pageErrors[0].message.includes("Quote items are not updatable when the Quote status is Won, Lost or Killed.")){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                        message: "No possibilities to modify the quote line item because the status is Won/lost/killed",
                                        type : "error"
                                    });
                                toastEvent.fire();
                                console.log('AN ERROR OCCURED saveSelectedConfig ' + state);
                                $A.get('e.force:refreshView').fire();
                  }
            }          
		});
		$A.enqueueAction(action);        
		}
    },
    validatescore: function(cmp, evt, mapopts) {
    	var qli = cmp.get("v.qli"); 
    	
    	var scoreval = (
    	(mapopts["disabledfields"].indexOf("Brand_Positionning__c") != -1 || (qli.Brand_Positionning__c)) && 
		(mapopts["disabledfields"].indexOf("DS_Multiple_Release_Order_Blanket_Order__c") != -1 || (qli.DS_Multiple_Release_Order_Blanket_Order__c)) && 
		(mapopts["disabledfields"].indexOf("DS_Est_purchase_order_contract_duration__c") != -1 || (qli.DS_Est_purchase_order_contract_duration__c)) && 
		(mapopts["disabledfields"].indexOf("DS_NB_month_of_stock_at_Albea_expenses__c") != -1 || (qli.DS_NB_month_of_stock_at_Albea_expenses__c)) && 
		(mapopts["disabledfields"].indexOf("DS_Number_of_suppliers_for_customers__c") != -1 || (qli.DS_Number_of_suppliers_for_customers__c)) && 
		(mapopts["disabledfields"].indexOf("DS_Indexation_of_raw_material_costs__c") != -1 || (qli.DS_Indexation_of_raw_material_costs__c)) && 
		(mapopts["disabledfields"].indexOf("DS_Non_stock_customer_requirements__c") != -1 || (qli.DS_Non_stock_customer_requirements__c)) && 
		(mapopts["disabledfields"].indexOf("DS_Tooling_CAPEX_investments_required__c") != -1 || (qli.DS_Tooling_CAPEX_investments_required__c)) && 
		(mapopts["disabledfields"].indexOf("DS_Exclusivity_Single_vs_Multiple_Supp__c") != -1 || (qli.DS_Exclusivity_Single_vs_Multiple_Supp__c)) && 
		(mapopts["disabledfields"].indexOf("DS_Penalties_customer_in_the_contract__c") != -1 || (qli.DS_Penalties_customer_in_the_contract__c)) && 
		(mapopts["disabledfields"].indexOf("DS_Type_of_business__c") != -1 || (qli.DS_Type_of_business__c)) && 
		(mapopts["disabledfields"].indexOf("DS_Penalties_in_the_contract_for_Albea__c") != -1 || (qli.DS_Penalties_in_the_contract_for_Albea__c))
    	)?true:false;
    	
    	scoreval = (qli.DS_Tooling_CAPEX_investments_required__c === 'Yes' && !qli.DS_Tooling_CAPEX_investment_required__c)?false:scoreval;
    	
	    cmp.set("v.validatescore", scoreval);
    	
    }
})