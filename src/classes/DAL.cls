public class DAL {
    
    // ***************************** BEGIN: QuoteLineItem queries ********************************** //
    // 
    public static QuoteLineItem getQuoteLineItemById(String quoteItemId){
        return [ 
            SELECT 
            // QuoteLineItem infos      
            Id, LineNumber, QuoteId, Billing_Currency__c, Billing_Currency_Rate__c, Billing_Currency_Position__c, Billing_Currency_Symbol__c, Additional_comments_on_customer_scoring__c,Business_at_other_product_line__c,Customer_EBB_rate__c,Market_Of_Application__c,
            Customer_end_of_year_rebate__c,Customer_Scoring__c,Customer_Type__c,Monthly_overdue_DSO__c,Payment_terms__c,Quality_requirement__c,Required_level_of_documentation__c,
            Service_Scoring__c,Sampling__c,Below_MOQs__c,Decoration_development__c,Product_Customization__c,Quantity,Deal_and_Context_Comments__c,
            Color_matching_process__c,Non_standard_supply_chain_process__c,Preproduction__c,Additionnal_comments_on_service_scoring__c,
            Regulatory_Affairs__c,Compatibility_Tests__c,R_D_Office__c,Spray_Tests__c,Training_for_customer__c,
            Product_Final_Look__c,
            // Quote infos                  
            Quote.Name, Quote.Project_Type__c, Quote.TOTAL_SCORING_SCORE__c, Quote.Tooling_CAPEX_investment_required__c,
            Quote.Quote_Due_Date__c, Quote.First_delivery_date__c,
            Quote.Main_compet_1__c, Quote.Main_compet_2__c,Quote.Additionnal_comments_on_deal_scoring__c,
            Quote.Deal_Scoring__c,Quote.Brand_Positionning__c,Quote.Contract_duration__c,Quote.Indexation_of_raw_material_costs__c,Quote.Exclusivity_Single_vs_Multiple_Supplier__c,
            Quote.Tooling_CAPEX_investments_required__c,Quote.Alb_a_dependency_to_supplier_s__c,Quote.Penalties_for_the_customer_in_the_contra__c,Quote.Type_of_business__c,
            Quote.Penalties_in_the_contract_for_Alb_a__c,Quote.Multiple_Release_Order_Blanket_Order__c,Quote.Skonto_for_cash_payment__c,Quote.of_month_of_stock_at_Alb_a_expenses__c,
            Quote.Est_purchase_order_contract_duration__c,Quote.Non_stock_customer_requirements__c,Quote.Number_of_suppliers_for_customers__c,
            
            //HM 20170521 - Deal Scoring is now in Quote Item
			Brand_Positionning__c, DS_NB_month_of_stock_at_Albea_expenses__c, DS_Contract_duration__c, DS_Indexation_of_raw_material_costs__c, 
			DS_Exclusivity_Single_vs_Multiple_Supp__c, DS_Tooling_CAPEX_investments_required__c, DS_Albea_dependency_to_suppliers__c, 
			DS_Penalties_customer_in_the_contract__c, DS_Type_of_business__c, DS_Penalties_in_the_contract_for_Albea__c, DS_Multiple_Release_Order_Blanket_Order__c, 
			DS_Skonto_for_cash_payment__c, DS_Additionnal_comments_on_deal_scoring__c, DS_Tooling_CAPEX_investment_required__c, 
			DS_Est_purchase_order_contract_duration__c, DS_Number_of_suppliers_for_customers__c, DS_Non_stock_customer_requirements__c, Deal_Scoring__c,         

            Total_Score__c,
            // loction EU/US
            Location__c,
            // Product2 infos 
            Product2.Family,
            //Product line    
            Product_line__c,
            // Product segment 
            //Product2.Product_Sub_Segment__r.Product_Segment_id__r.Name, 
            //Product2.Product_Sub_Segment__r.Short_description__c,
            Product_Sub_segment__c,
            // if purefoil segment (when Product_Sub_segment__c = 'Plastic Tubes' )
            Purefoil_segment__c,
            // Opportunity infos
            Quote.OpportunityId, Quote.Opportunity.Name, Quote.Opportunity.Account_manager_KAM__c, 
            Quote.Opportunity.Sales_manager__c, Quote.Opportunity.Sales_director__c, 
            Quote.Opportunity.CloseDate,
            // Account infos 
            Quote.Opportunity.AccountId, Quote.Opportunity.Account.Name, Quote.Opportunity.Account.Type, 
            Quote.Opportunity.Account.Customer_size_PM__c,
            // Account.country infos
            Quote.Opportunity.Account.Country__r.Name,                                                  
            // Customer_Group__c infos
            Quote.Opportunity.Account.Customer_Group__r.Name        
            FROM QuoteLineItem 
            WHERE Id = :quoteItemId
            LIMIT 1] ;
 
    }
    // ***************************** END: QuoteLineItem queries ********************************** //
	
	/*
	*@description: popular Select * SQL syntax in SOQL
	*/
	public static string generateSELECTQuery(String objectAPIName){
		// Initialize setup variables
		String objectName = objectAPIName;
		String query = 'SELECT';
		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
		
		// Grab the fields from the describe method and append them to the queryString one by one.
		for(String s : objectFields.keySet()) {
		   query += ' ' + s + ', ';
		}
		
		// Strip off the last comma if it exists.
		if (query.subString(query.Length()-2,query.Length()-1) == ','){
		    query = query.subString(0,query.Length()-2);
		}
		
		// Add FROM statement
		query += ' FROM ' + objectAPIName+' ';
		
		return query;
	}//end generateSELECTQuery

}