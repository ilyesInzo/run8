/**
* @description Service class for interacting with QuoteLineItem
* @author MDK
* @date 07/11/2017
*/
public class QuoteLineItemService extends QuoteService {
    /**
     * <b>LOG_CLASS_NAME </b>: used for system.debug 
     */
    public static String LOG_CLASS_NAME = 'QuoteLineItemService';

    ///////////////////////////////////////////////////////////////////////////////
    // WHEN CHILD CLASS EXTENDS AN ABSTRACT PARENT CLASS WE CAN'T USE STATIC METHOD
    // OF THE PARENT SO WE HAVE TO IMPLEMENT THE SINGLETON PATTERN
    ///////////////////////////////////////////////////////////////////////////////
    Private static final String authProfilsId 			= Label.AUTHORIZED_PROFILSID_PMUpdate;
   	Private static final String pmEligibleSubSegment 	= Label.Label_PM_Eligible_ProductSubSegment;

    //Added by Thanina ************
    Private static final String authoProfilesIDToDelQLI = Label.Auth_Profile_Delete;

    //*****************************
    /**
     * @description Singleton : private static variable referencing the class
     */
    private static QuoteLineItemService instance = null;

    /**
     * @description SalesTeamService : private constructor (Singleton pattern)]
     * @return a new instance of the class
     */
    private QuoteLineItemService() {
    }

    /**
     * @description getInstance : a static method that returns the unique instance of the class (Singleton pattern)
     * @return a new instance of the class
     */
    public static QuoteLineItemService getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if (instance == null) {
            instance = new QuoteLineItemService();
        }
        return instance;
    }
    ///////////////////////////////////////////////////////////////////////////////

    /**
     * @description Transcode the plant field entered by the user to the correct apiName
     * @param String : enteredString
     * @return String
     */
    public String transcoPlantName(String enteredString){
        System.debug(LoggingLevel.ERROR,'QuoteLineItemService.setQuoteLineItems : dans TRANSCO-------');
        Schema.DescribeFieldResult fieldResult = QuotelineItem.Production_Plant__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        System.debug(LoggingLevel.ERROR,'QuoteLineItemService.setQuoteLineItems : enteredString = '+enteredString);
        for( Schema.PicklistEntry f : ple){             
            if(f.getLabel() == enteredString)
                return f.getValue();            
        }
        
        return '';
           
    }

    
    /**
     * @description get QuoteLineItem by Ids
     * @param quoteLineItemIds
     * @return Map of QuoteLineItem by Ids
     */
    public Map<Id, QuoteLineItem> getQuoteLineItemByIds(Set<Id> quoteLineItemIds){
        return new Map<Id, QuoteLineItem>([ 
            SELECT 
                // QuoteLineItem infos      
                Id, LineNumber, QuoteId, Billing_Currency__c, Billing_Currency_Rate__c, Billing_Currency_Position__c, Billing_Currency_Symbol__c, Additional_comments_on_customer_scoring__c,Business_at_other_product_line__c,Customer_EBB_rate__c,Market_Of_Application__c,
                Customer_end_of_year_rebate__c,Customer_Scoring__c,Customer_Type__c,Monthly_overdue_DSO__c,last_QLI_Payment_term__c,Payment_terms__c,Quality_requirement__c,Required_level_of_documentation__c,
                Service_Scoring__c,Sampling__c,Below_MOQs__c,Decoration_development__c,Product_Customization__c,Quantity,Deal_and_Context_Comments__c,
                Color_matching_process__c,Non_standard_supply_chain_process__c,Preproduction__c,Additionnal_comments_on_service_scoring__c,
                Regulatory_Affairs__c,Compatibility_Tests__c,R_D_Office__c,Spray_Tests__c,Training_for_customer__c,
                Product_Final_Look__c,Product_Brand_Name_to_be_added__c,
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

                Total_Score__c, copy_quote_status__c,
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
                Quote.OpportunityId, Quote.Opportunity.Name,
                Quote.Opportunity.KAMFullName__c,Quote.Opportunity.SalesManagerFullName__c,
                Quote.Opportunity.SalesDirectorFullName__c,Quote.Opportunity.SalesAdditionalFullName__c, 
                Quote.Opportunity.CloseDate,
                // Account infos 
                Quote.Opportunity.AccountId, Quote.Opportunity.Account.Name, Quote.Opportunity.Account.Type, 
                Quote.Opportunity.Account.Customer_size_PM__c,
                // Account.country infos
                Quote.Opportunity.Account.Country__r.Name,                                                  
                // Customer_Group__c infos
                Quote.Opportunity.Account.Customer_Group__r.Name        
            FROM QuoteLineItem 
            WHERE Id In :quoteLineItemIds]);

    }
/**
     * @description set QuoteLineItem values before the Insert or Update
     * @param newQuoteLineIems : trigger.new
     * @return nothing
     
    public void setQuoteLineItems(List<QuoteLineItem> newQuoteLineItems) {
    }*/
    /**
     * @description set QuoteLineItem values before the Insert or Update
     * @param newQuoteLineIems : trigger.new
     * @return nothing
     */
    public void setQuoteLineItems(List<QuoteLineItem> newQuoteLineItems) {      
        
        //HM 20170521 - Deal Scoring is now in Quote Item
        //Copy the quote Deal Scoring to QuoteLineItem Deal Scoring
        System.debug(LoggingLevel.ERROR,'QuoteLineItemService.setQuoteLineItems : COPY DEAL SCORING ==============');

        Map<Id, Quote> quotesById = getQuotesInfo(SObjectUtils.toSetOfId(newQuoteLineItems, 'QuoteId'));

        System.debug(LoggingLevel.ERROR,'QuoteLineItemService.setQuoteLineItems : '+quotesById);
	 	
	 	map<string,Boolean> accessMapPM = mapAccessToPM();	
        // Set the QuoteLineItem values
        for(QuoteLineItem qli : newQuoteLineItems) {

            Quote quote = quotesById.get(qli.QuoteId);

            if (quote != null) {

               /* qli.Brand_Positionning__c = quote.Brand_Positionning__c; 
                qli.DS_NB_month_of_stock_at_Albea_expenses__c = quote.Of_month_of_stock_at_Alb_a_expenses__c;
                qli.DS_Contract_duration__c = quote.Contract_duration__c;
                qli.DS_Indexation_of_raw_material_costs__c = quote.Indexation_of_raw_material_costs__c;
                qli.DS_Exclusivity_Single_vs_Multiple_Supp__c = quote.Exclusivity_Single_vs_Multiple_Supplier__c;
                qli.DS_Tooling_CAPEX_investments_required__c = quote.Tooling_CAPEX_investments_required__c;
                qli.DS_Albea_dependency_to_suppliers__c = quote.Alb_a_dependency_to_supplier_s__c;
                qli.DS_Penalties_customer_in_the_contract__c = quote.Penalties_for_the_customer_in_the_contra__c;
                qli.DS_Type_of_business__c = quote.Type_of_business__c;
                qli.DS_Penalties_in_the_contract_for_Albea__c = quote.Penalties_in_the_contract_for_Alb_a__c;
                qli.DS_Multiple_Release_Order_Blanket_Order__c = quote.Multiple_Release_Order_Blanket_Order__c;
                qli.DS_Skonto_for_cash_payment__c = quote.Skonto_for_cash_payment__c;
                qli.DS_Additionnal_comments_on_deal_scoring__c = quote.Additionnal_comments_on_deal_scoring__c;
                qli.DS_Tooling_CAPEX_investment_required__c = quote.Tooling_CAPEX_investment_required__c;                           
                qli.DS_Est_purchase_order_contract_duration__c = quote.Est_purchase_order_contract_duration__c;
                qli.DS_Number_of_suppliers_for_customers__c = quote.Number_of_suppliers_for_customers__c;
                qli.DS_Non_stock_customer_requirements__c = quote.Non_stock_customer_requirements__c;    */       
                                 
                System.debug(LoggingLevel.ERROR,'QuoteLineItemService.setQuoteLineItems : '+qli.QuoteId + '===' + qli.Brand_Positionning__c + '==='+quote.Brand_Positionning__c);
            }//end if quote !=null
            
            //added by maryem qada to determine if a quoteline item should be filled using PriceMatrix or not !
           	string key = quote.Opportunity.Account.Country__r.Country_Code__c +'_'+qli.product_line__c+'_'+  quote.Project_Type__c;
            system.debug('@@qama key '+ key);
            if(qli.Product_Sub_segment__c != null && pmEligibleSubSegment.contains(qli.Product_Sub_segment__c))
            	qli.isPriceMatrix__c =  accessMapPM.get(key) != null  ? accessMapPM.get(key) :false;            
                          
        }
        
        System.debug(LoggingLevel.ERROR,'QuoteLineItemService.setQuoteLineItems : END COPY DEAL SCORING ==============');
        
        // This method does an update of Opportunity and an insert of OpportunityTeamMember
        Map<QuoteLineItem,Boolean> qliAllocationCheckMap = SalesTeamService.getInstance().checkQLIAllocation(newQuoteLineItems);            
        if (!qliAllocationCheckMap.isEmpty()) {
            //Check Allocation
            For(QuoteLineItem qli : newQuoteLineItems){
                // bypass should be manage by role or profile when role and profile will be implemented
                // if it's done set the TriggerHandler.bypassTriggers variable as private
                System.debug(LoggingLevel.ERROR,'QuoteLineItemService.setQuoteLineItems AllocationCheckMap = '+qliAllocationCheckMap.get(qli));
                System.debug(LoggingLevel.ERROR,'QuoteLineItemService.setQuoteLineItems bypassTriggers = '+TriggerHandler.bypassedTriggers.contains('QLITH.SA_ERRMSG'));        
                if(!qliAllocationCheckMap.get(qli) && !TriggerHandler.bypassedTriggers.contains('QLITH.SA_ERRMSG')){
                    qli.addError(System.label.QUOTELINEITEM_SALESALLOCATION_ERRMSG);      
                } else if (qliAllocationCheckMap.get(qli)) {
                    System.debug(LoggingLevel.ERROR,'QuoteLineItemService.setQuoteLineItems : user has allocations');
                }
            }            
        }

     }
    
     /**
     * @description checkElligibilityOfUpdate for price/moq unit PM
     * @param newQuoteLineItems , oldQuoteLineItemsById
     * @return void
     */
    public static void checkElligibilityOfUpdate(List<quotelineitem> newQuoteLineItems, map<id,quotelineitem> oldQuoteLineItemsById){
    	System.debug('-------------check eligi');
        //check if a bypass is necessary depending on profils
       if(!authProfilsId.contains(UserInfo.getProfileId())){ 
        	for(quotelineitem qli :newQuoteLineItems){ 
        		System.debug('-------------check eligi'+(qli.id_calculette__c));
        		if(pmEligibleSubSegment.contains(qli.Product_Sub_segment__c)){
        			//check if the salesprice or the moq unit has been updated
		            if((qli.Sales_price_per_1000__c != oldQuoteLineItemsById.get(qli.id).sales_price_per_1000__c
		              || qli.Minimum_Order_Quantity__c != oldQuoteLineItemsById.get(qli.id).Minimum_Order_Quantity__c)
		              &&  //LC01_OpenPriceMatrix.displaybuttonvalidation(qli.ID) 
		              	qli.isPricematrix__c == true){//Do the control only for Price Matrix Records
		              	qli.tech_validation_error_update_qli__c ='UNAUTHORIZED UPDATE';  	
		              }
		              else{
		              	qli.tech_validation_error_update_qli__c ='NONE';	
		              }	 
        		}//end if eligible subsegment 
         	}//end for qlis		
        }//end if authProfilID DECOMMENT TEST FAST TRACK PROFIL ADMIN
        	
    }
    
    /**
     * @description reinitBypasses  
     * @param newQuoteLineItems  
     * @return void
     */
    public static void reinitBypasses(List<quotelineitem> newQuoteLineItems ){
		System.debug('-------------reinitBypasses');
        //in case of bypass VR, reinit record values
        List<Quotelineitem> liQlisToUpdate = new list<quotelineitem>();
        
        for(quotelineitem qli : newQuoteLineItems){
        	if(qli.Bypass_VR__c 
        	 || qli.tech_validation_error_update_qli__c =='UNAUTHORIZED UPDATE'){
        		Quotelineitem qi = new quotelineitem(id = qli.id);        		
        		qi.Bypass_VR__c =false;        		
        		qi.tech_validation_error_update_qli__c = 'NONE';
        		
        		liQlisToUpdate.add(qi);
        	}
        	
        }
        update liQlisToUpdate;	
    }
       
    /**
     * @description mapAccessToPM  
     * @param void
     * @return  map<string,Boolean>
     */
    public static map<string,Boolean> mapAccessToPM(){
    	        
    	String tableName = 'Access to PricematriX by PL,zone, country';
        String PRICEMATRIX_EUROPE = 'PricematriX Europe';
        String PRICEMATRIX_AMERICAS = 'PricematriX Americas'; 
       
        map<string,boolean> mapAccessToPM = new map<string,boolean>();
         
       	//DISP , P0 , P0plus & P1
        for(PM_Global_Config__c gConf :[SELECT Id,Product_Line_Tubes__c, Product_Line_Dispensing__c ,Country_code__c, PricematriX_used_for_P0__c, PricematriX_used_for_P0plus__c, PricematriX_used_for_P1__c
        											FROM PM_Global_Config__c 
        											WHERE Table_Name__c = :tableName
        											AND (Product_Line_Dispensing__c = :PRICEMATRIX_EUROPE OR Product_Line_Dispensing__c = :PRICEMATRIX_AMERICAS)]){
        	
        	if(gConf.PricematriX_used_for_P0__c == true) mapAccessToPM.put(gConf.Country_code__c+'_'+Label.Label_ProductLine_Dispensing+'_P0',true);	
        	if(gConf.PricematriX_used_for_P0plus__c == true) mapAccessToPM.put(gConf.Country_code__c+'_'+Label.Label_ProductLine_Dispensing+'_P0+',true);
        	if(gConf.PricematriX_used_for_P1__c == true) mapAccessToPM.put(gConf.Country_code__c+'_'+Label.Label_ProductLine_Dispensing+'_P1',true);	
        }      
        
        //TUBE , P0 P0plus & P1
        for(PM_Global_Config__c gConf :[SELECT Id,Product_Line_Tubes__c, Product_Line_Dispensing__c ,Country_code__c, PricematriX_used_for_P0__c, PricematriX_used_for_P0plus__c, PricematriX_used_for_P1__c
        											FROM PM_Global_Config__c 
        											WHERE Table_Name__c = :tableName
        											AND (Product_Line_Tubes__c = :PRICEMATRIX_EUROPE OR Product_Line_Tubes__c = :PRICEMATRIX_AMERICAS)]){
        												
       		if(gConf.PricematriX_used_for_P0__c == true) mapAccessToPM.put(gConf.Country_code__c+'_'+Label.Label_ProductLine_Tubes+'_P0',true);	
        	if(gConf.PricematriX_used_for_P0plus__c == true) mapAccessToPM.put(gConf.Country_code__c+'_'+Label.Label_ProductLine_Tubes+'_P0+',true);	
        	if(gConf.PricematriX_used_for_P1__c == true) mapAccessToPM.put(gConf.Country_code__c+'_'+Label.Label_ProductLine_Tubes+'_P1',true);	
        	
        }
       	return mapAccessToPM;     	
    }    

    /** 
     * [setLocation description : will set the localisation                         ]
     * @author EWA
     * @param newQuoteLineItems [ List<QuoteLineItem> : ]
     */
    public static void setLocation(List<QuoteLineItem> newQuoteLineItems){

        System.debug(LoggingLevel.INFO , LOG_CLASS_NAME + ' - setLocation Start');

        // Constant declaration
        final String PRICEMATRIX_EUROPE = 'PricematriX Europe';
        final String PRICEMATRIX_AMERICAS = 'PricematriX Americas';

        //1. We're going to select the elligible quote line item
        List<QuoteLineItem> eligibleQlis = new List<QuoteLineItem>();
        Set<String> eligibleProductSegment = new Set<String>(System.Label.Label_PM_Eligible_ProductSubSegment.split(';'));
        for(QuoteLineItem newQuoteLineItem : newQuoteLineItems){
            if(((newQuoteLineItem.Product_Line__c == System.Label.Label_ProductLine_Tubes) ||
                            (newQuoteLineItem.Product_Line__c == System.Label.Label_ProductLine_Dispensing)) &&
                (eligibleProductSegment.contains(newQuoteLineItem.Product_Sub_segment__c)))
                eligibleQlis.add(newQuoteLineItem);
        }

        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - eligibleQlis.size() : ' + eligibleQlis.size());

        //2. We're going to get all the quote concern by the quoteLineItem
        Set<Id> quoteIds = new Set<Id>();
        for(QuoteLineItem eligibleQli : eligibleQlis){
            if(((eligibleQli.Product_Line__c == System.Label.Label_ProductLine_Tubes) ||
                            (eligibleQli.Product_Line__c == System.Label.Label_ProductLine_Dispensing)) &&
                (eligibleProductSegment.contains(eligibleQli.Product_Sub_segment__c))){
                quoteIds.Add(eligibleQli.QuoteId);
            }
        }
        Map<Id, Quote> quotes = new Map<Id, Quote>([SELECT Id, AccountId FROM Quote WHERE Id IN: quoteIds]);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' quotes.size() : ' + quotes.size());

        //3. We're going to get all the Account concern by the quote
        Set<Id> accountIds = new Set<Id>();
        for(Id quoteId : quoteIds){
            Quote quote = quotes.get(quoteId);
            accountIds.Add(quote.AccountId);
        }
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Country__c FROM Account WHERE Id IN: accountIds]);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' accounts.size() : ' + accounts.size());
 
        //4. We're going to get all the Country concern by the account
        Set<Id> countryIds = new Set<Id>();
        for(Id accountId : accountIds){
            Account account = accounts.get(accountId);
            countryIds.Add(account.Country__c);
        }
        Map<Id, Country__c> countries = new Map<Id, Country__c>([SELECT Id, Country_Code__c FROM Country__c WHERE Id IN: countryIds]);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' countries.size() : ' + countries.size());

        //5. We're going to get the zone code corresponding to the country code
        Set<String> countryCodes = new Set<String>();
        for(Id countryId : countryIds){
            countryCodes.add(countries.get(countryId).Country_Code__c);
        }
        List<PM_Global_Config__c> pmGlobalConfigs = [SELECT Id, Country_code__c, Product_Line_Tubes__c, Product_Line_Dispensing__c
                                                FROM PM_Global_Config__c WHERE Country_code__c IN :countryCodes];

        Map<String, PM_Global_Config__c> countryCodeToGlobalConfigMapping = new Map<String, PM_Global_Config__c>();
        for(PM_Global_Config__c pmGlobalConfig : pmGlobalConfigs){
            countryCodeToGlobalConfigMapping.put(pmGlobalConfig.Country_code__c, pmGlobalConfig);
        }

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' pmGlobalConfigs.size() : ' + pmGlobalConfigs.size());

        //6. We're going to link the quote to the corresponding Zone Code
        Map<Id, Quote> qliToQuoteMapping = new Map<Id, Quote>();
        for(QuoteLineItem eligibleQli : eligibleQlis){
            System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' eligibleQli.QuoteId : ' + eligibleQli.QuoteId);
            qliToQuoteMapping.put(eligibleQli.Id, quotes.get(eligibleQli.QuoteId));
        }

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' qliToQuoteMapping.size() : ' + qliToQuoteMapping.size());


        Map<Id, Account> qliToAccountMapping = new Map<Id, Account>();
        for(QuoteLineItem eligibleQli : eligibleQlis){
            qliToAccountMapping.put(eligibleQli.Id, accounts.get(qliToQuoteMapping.get(eligibleQli.Id).AccountId));
        }

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' qliToAccountMapping.size() : ' + qliToAccountMapping.size());


        Map<Id, Country__c> qliToCountryMapping = new Map<Id, Country__c>();
        for(QuoteLineItem eligibleQli : eligibleQlis){
            qliToCountryMapping.put(eligibleQli.Id, countries.get(qliToAccountMapping.get(eligibleQli.Id).Country__c));
        }

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' qliToCountryMapping.size() : ' + qliToCountryMapping.size()); 

        Map<Id, PM_Global_Config__c> qliToGlobalConfig = new Map<Id, PM_Global_Config__c>();
        for(QuoteLineItem eligibleQli : eligibleQlis){
            qliToGlobalConfig.put(eligibleQli.Id, countryCodeToGlobalConfigMapping.get(qliToCountryMapping.get(eligibleQli.Id).Country_code__c));
        }
       
        //7. The only thing left to do is to update the QuoteLineItem 
        List<QuoteLineItem> qliToUpdate = new List<QuoteLineItem>();
        for(QuoteLineItem eligibleQli : eligibleQlis){            
            System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' qliToQuoteMapping.get(eligibleQli.Id) : ' + qliToQuoteMapping.get(eligibleQli.Id));
            System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' qliToAccountMapping.get(eligibleQli.Id) : ' + qliToAccountMapping.get(eligibleQli.Id));
            System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' qliToCountryMapping.get(eligibleQli.Id) : ' + qliToCountryMapping.get(eligibleQli.Id));            
            System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' qliToGlobalConfig.get(eligibleQli.Id) : ' + qliToGlobalConfig.get(eligibleQli.Id));
            PM_Global_Config__c globalConfig = qliToGlobalConfig.get(eligibleQli.Id);
            if(globalConfig != null){               
                String accessForProductLineTubes = globalConfig.Product_Line_Tubes__c;
                String accessForProductLineDispensing = globalConfig.Product_Line_Dispensing__c;
                if(accessForProductLineTubes == PRICEMATRIX_EUROPE || accessForProductLineDispensing == PRICEMATRIX_EUROPE ){
                    eligibleQli.Location__c = 'EU';
                }else if(accessForProductLineTubes == PRICEMATRIX_AMERICAS || accessForProductLineDispensing == PRICEMATRIX_AMERICAS ){
                    eligibleQli.Location__c = 'US';
                }
                qliToUpdate.add(eligibleQli);
            }
        }

        //8. Send the updated QuoteLineItem in the database
        //update qliToUpdate; 

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - setLocation Stop');

    }
     /**
     * @description set the last filled brand and set it in new QLIs
     * @param String : list of new Quotelineitems
     * @return void
     */
    public static void setBrandName(List<QuoteLineItem> newQuoteLineItems){
        ID relatedOpportunityID ;
        Id brand ;       
        Id brandAccount ; 
        Id brandCustGroup ; 
        String brandToBeAdded;
        
        //get the ID of the parent opportunity
        relatedOpportunityID = (newQuoteLineItems.size()>0 && newQuoteLineItems!= null ? [select opportunityid from quote where id = :newQuoteLineItems[0].quoteid  limit 1].opportunityid : null);
         
        //get the last modified quote
        map<id,quote> mapLastModifiedQuoteID = new map<id,quote>([select id from quote where opportunityID = :relatedOpportunityID Order by lastmodifieddate DESC ]); 
        
        //get the last modified QLI
        list<quotelineitem> listQlis = [select brand__c,Tech_Account__c,Product_Brand_Name_to_be_added__c,Tech_Customer_Group__c  from quotelineitem 
        					where brand__c!= null and quoteid = :mapLastModifiedQuoteID.keyset() 
        					Order by lastmodifieddate desc];
        
        if(listQlis.size()>0 && listQlis != null ){
        	brand = listQlis[0].brand__c;
        	brandAccount =listQlis[0].Tech_Account__c ;
        	brandCustGroup	 =listQlis[0].Tech_Customer_Group__c ;
        	brandToBeAdded = listQlis[0].Product_Brand_Name_to_be_added__c;
	        for(quotelineitem qli : newQuoteLineItems){
	        	qli.brand__c =brand; 
	        	qli.Product_Brand_Name_to_be_added__c= brandToBeAdded;
	        	qli.Tech_Account__c=brandAccount;
	        	qli.Tech_Customer_Group__c=brandCustGroup;
	        }
        }         
    }
    
     /**
     * @description set the last filled brand and set it in new QLIs
     * @param String : list of new Quotelineitems
     * @return void
     */
    public static void createPMReviewPerMoqRecords(list<QuoteLineItem> newQuoteLineItems){
    	system.debug('------------- createPMReviewPerMoqRecords -----------------------' );
    	list<PM_Review_NetPrice_per_MOQ__c> liRecordsToCreate = new list<PM_Review_NetPrice_per_MOQ__c>();    	
    	map<id,integer> mapIdQLiToNumberOfChilds = new map<id,integer>();    	
    	set<id> newQuoteLineItemsID = new set<id>();
    	
    	for(QuoteLineItem qli :newQuoteLineItems) {
    		if(qli.ispricematrix__c)
    		newQuoteLineItemsID.add(qli.id);
    	}
    	//fill the map of num of childs per QLI
    	//init the map
    	for(ID qli :newQuoteLineItemsID) {
    		mapIdQLiToNumberOfChilds.put(qli,0 );
    	}
    	for(AggregateResult ar:[SELECT COUNT(Id), Quote_Line_Item__c 
    										FROM PM_Review_NetPrice_per_MOQ__c 
    										where Quote_Line_Item__c IN :newQuoteLineItemsID 
    										GROUP BY Quote_Line_Item__c ]) {
    		mapIdQLiToNumberOfChilds.put((ID)ar.get('Quote_Line_Item__c'),(INTEGER)ar.get('expr0') );
    	}
    	
    	for(Id idQLi : newQuoteLineItemsID){
    		//check if there is all the PM Review records
    		if(mapIdQLiToNumberOfChilds.get(idQli) <7){
    			liRecordsToCreate.addAll(createPMReviewRecords(7- mapIdQLiToNumberOfChilds.get(idQli),idQli ));
    		}	
    	}//end for qlis
    	insert liRecordsToCreate;
    	
    }//end createPMReviewPerMoqRecords
    
    public static list<PM_Review_NetPrice_per_MOQ__c> createPMReviewRecords(Integer numbertocreate,Id idQliToAttach){
    	list<PM_Review_NetPrice_per_MOQ__c> listToReturn= new list<PM_Review_NetPrice_per_MOQ__c>();
    	
    	for(integer i=0 ; i<numbertocreate;i++)
    		listToReturn.add(
    			new PM_Review_NetPrice_per_MOQ__c(Quote_Line_Item__c=idQliToAttach )
    		);
    		system.debug(listToReturn);
    	return listToReturn;
    }//end createPMReviewRecords

    //added by Thanina.
    public static void copyCustomerScoringFromAccount(List<QuoteLineItem> listNewQLI)
    {
        for(QuoteLineItem qli:listNewQLI)
        {
            if(qli.Quote.Opportunity.Account != Null)
            {
                if(qli.Quote.Opportunity.Account.Business_at_other_product_line__c != null && qli.Quote.Opportunity.Account.Business_at_other_product_line__c !='')
                    qli.Business_at_other_product_line__c = qli.Quote.Opportunity.Account.Business_at_other_product_line__c;
                else System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@The value is null');
            }
            else System.debug('@@@@@@@@@Account is Null: ');
        }
    }

    // Check if the connected user can Delete QLI

    public static void checkCanDeleteQLI(Map<ID,QuoteLineItem> oldListQLI)
    {
        if(!authoProfilesIDToDelQLI.contains(UserInfo.getProfileId()))
        {
            for(QuoteLineItem qli:oldListQLI.values())
            {
                if(!(qli.copy_quote_status__c.equalsIgnoreCase('Draft') || qli.copy_quote_status__c.equalsIgnoreCase('Simulation')))
                          qli.addError(Label.Delete_QLI_Msg);
            }
        }

        //List<QuoteLineItem> toUpQLI= new List<QuoteLineItem>();
        //List<QuoteLineItem> listInit=[select id,QuoteId, copy_quote_status__c,Cant_Delete__c from QuoteLineItem where id in :oldListQLI.keySet()];
      //  List<Quote> toUpQuotes= new List<Quote>();

        //if(!authoProfilesIDToDelQLI.contains(UserInfo.getProfileId()))
        //{
          /*  for(QuoteLineItem qli:listInit)
            {
                if(!qli.copy_quote_status__c.equalsIgnoreCase('Draft'))
                {
                    qli.Cant_Delete__c = true;
                   // toUpQuotes.add(new Quote(ID= qli.QuoteId,Cant_Delete_QLI_Quote__c = true));
                    System.debug('@@@@@@I am Here 1');
                }
                else
                {
                    qli.Cant_Delete__c = false;
                    System.debug('@@@@@@I am Here 2');
                   // toUpQuotes.add(new Quote(ID= qli.QuoteId,Cant_Delete_QLI_Quote__c = false));
                }
                toUpQLI.add(qli);

            }*/
        //}

       // if(toUpQuotes.size() > 0 ) update toUpQuotes;
       // if(toUpQLI.size() > 0) update toUpQLI;

    }
    
    public static void deleteRelatedConfig(Map<ID,QuoteLineItem> oldListQLI)
    {

        String tubeProducts = 'Plastic Tubes,Laminate Tubes';
        String dispensingProducts ='Foam pumps,Fine mist pumps,Lotion pumps,Sampler pumps';
        Set<id> dispensingProductsSet = new Set<Id>();
        Set<id> tubeProductsSet = new Set<Id>();
        
        for(QuoteLineItem qli : oldListQLI.values() ){
             if(dispensingProducts.contains(qli.Product_Sub_segment__c)){
             	dispensingProductsSet.add(qli.id);
             }
             else if(tubeProducts.contains(qli.Product_Sub_segment__c)){
             	tubeProductsSet.add(qli.id);
             }
        }
        
          List<PM_Selected_Dipsensing_config__c> selectedDispensingConfig = [select id,Name,Quote_item__c,
                  Product_Segment__c,Location__c from PM_Selected_Dipsensing_config__c
                  where Quote_item__c in : dispensingProductsSet];
        
          delete selectedDispensingConfig;         

          List<PM_Selected_Tubes_config__c> selectedTubeConfig = [select id,Name,Quote_item__c,
                  Product_Segment__c,Location__c from PM_Selected_Tubes_config__c
                  where Quote_item__c in : tubeProductsSet];

          delete selectedTubeConfig; 
        
          List<PM_Price_Recommendation__c> priceRecommendation = [select id,Name,Quote_Line_Item__c from PM_Price_Recommendation__c
                  where Quote_Line_Item__c in : oldListQLI.keySet()]; 
		
          delete priceRecommendation;
        
          List<PM_Price_Detail__c> priceDetail = [select id,Name,Quote_item__c from PM_Price_Detail__c
                  where Quote_item__c in : oldListQLI.keySet()]; 
		
          delete priceDetail;
        
          List<PM_MOQ_price__c> priceMoq = [select id,Name,Quote_item__c from PM_MOQ_price__c
                  where Quote_item__c in : oldListQLI.keySet()]; 
		
          delete priceMoq;
        
    }

    public static void setQliInformation(List<QuoteLineItem> newQuoteLineItems) {
        set<id> quotesIds = new set<id>();
        set<Id> productIds = new set<Id>();
        set<Id> brandIds = new set<Id>();
        for (QuoteLineItem qli:newQuoteLineItems){
            quotesIds.add(qli.QuoteId);
            productIds.add(qli.Product2Id);
            brandIds.add(qli.Brand__c);
        }

        map<id, Product2> relatedProducts = new map<id, Product2> ([select Id, Name
        from Product2
        where Id IN: productIds]) ;
        map<Id , QuoteLineItem>  LastQuoteLine = new map<Id,QuoteLineItem>( [select QuoteId,id,Deal_Scoring__c,Brand_Positionning__c,DS_Additionnal_comments_on_deal_scoring__c,DS_Albea_dependency_to_suppliers__c,DS_Contract_duration__c,
    DS_Est_purchase_order_contract_duration__c, DS_Exclusivity_Single_vs_Multiple_Supp__c,DS_Indexation_of_raw_material_costs__c,
    DS_Multiple_Release_Order_Blanket_Order__c,DS_NB_month_of_stock_at_Albea_expenses__c,
    DS_Non_stock_customer_requirements__c,DS_Number_of_suppliers_for_customers__c,DS_Penalties_customer_in_the_contract__c,
        DS_Penalties_in_the_contract_for_Albea__c,DS_Skonto_for_cash_payment__c,DS_Tooling_CAPEX_investment_required__c,
         DS_Type_of_business__c,DS_Tooling_CAPEX_investments_required__c,Payment_terms__c
         from QuoteLineItem
        where QuoteId IN : quotesIds and Last_created__c=1] );
        map<Id , QuoteLineItem>  LastQuoteQLI = new map<Id,QuoteLineItem>();
        for(QuoteLineItem ql: LastQuoteLine.Values())
        {
            LastQuoteQLI.put(ql.QuoteId,ql);
        }

        map<Id , Quote>  relatedQuotes = new map<Id,Quote>( [select Id ,
                Opportunity.Account.Customer_Type__c, Brand_Positionning__c,Opportunity.Account.Payment_terms__c,
                Opportunity.Account.Business_at_other_product_line__c, Opportunity.Account.Additional_comments_on_customer_scoring__c,
                Opportunity.Account.Customer_EBB_rate__c,
                Opportunity.Account.Customer_end_of_year_rebate__c,
                Opportunity.Account.Monthly_overdue_DSO__c,
                Opportunity.Account.Quality_requirement__c, Opportunity.Account.Required_level_of_documentation__c,
                Additionnal_comments_on_deal_scoring__c,
                Alb_a_dependency_to_supplier_s__c, Contract_duration__c,
                Est_purchase_order_contract_duration__c, Exclusivity_Single_vs_Multiple_Supplier__c,
                Indexation_of_raw_material_costs__c, Multiple_Release_Order_Blanket_Order__c,
                of_month_of_stock_at_Alb_a_expenses__c, Non_stock_customer_requirements__c,
                Number_of_suppliers_for_customers__c, Penalties_for_the_customer_in_the_contra__c,
                Penalties_in_the_contract_for_Alb_a__c, Skonto_for_cash_payment__c,
                Tooling_CAPEX_investment_required__c, Tooling_CAPEX_investments_required__c,
                Type_of_business__c,
                Opportunity.Account.Customer_Group__c, Opportunity.Account.Customer_Group__r.Name,
                Opportunity.Account.Customer_Group__r.Id, Quote.Opportunity.AccountId,
                Opportunity.Account.Name, Count_Quote_line_item__c,Last_created_QLI__c

        from Quote
        where Id IN : quotesIds] );

        map<Id, Brand__c> relatedBrands = new map<Id, Brand__c>([select Id, Name from Brand__c
        where Id IN: brandIds]);
        
        for (QuoteLineItem qli:newQuoteLineItems) {
            Boolean tube = false;
            // Set Product Segment
            switch on relatedProducts.get(qli.Product2Id).Name {
                when 'Accessories' {
                    qli.Sub_Segment_Copy__c = 'Accessories';
                }
                when 'Compact' {
                    qli.Sub_Segment_Copy__c = 'Compact';
                }
                when 'Eyeliner' {
                    qli.Sub_Segment_Copy__c = 'Eyeliner';
                }
                when 'Full Service' {
                    qli.Sub_Segment_Copy__c = 'Full Service';
                }
                when 'Lipgloss' {
                    qli.Sub_Segment_Copy__c = 'Lipgloss';
                }
                when 'Lipsticks' {
                    qli.Sub_Segment_Copy__c = 'Lipsticks';
                }
                when 'Mascara' {
                    qli.Sub_Segment_Copy__c = 'Mascara';
                }
                when 'Sampler pumps' {
                    qli.Sub_Segment_Copy__c = 'Sampler pumps';
                }
                when 'Fine mist pumps' {
                    qli.Sub_Segment_Copy__c = 'Fine mist pumps';
                }
                when 'Foam pumps' {
                    qli.Sub_Segment_Copy__c = 'Foam pumps';
                }
                when 'Lotion pumps' {
                    qli.Sub_Segment_Copy__c = 'Lotion pumps';
                }
                when 'Laminate Tubes' {
                    qli.Sub_Segment_Copy__c = 'Laminate Tubes';
                    tube=true;
                }
                when 'Plastic Tubes' {
                    qli.Sub_Segment_Copy__c = 'Plastic Tubes';
                    tube=true;
                }
            }

            // set currency
            if (qli.isPriceMatrix__c){
                switch on qli.location__c {
                    when 'EU'{
                        qli.Billing_Currency__c = 'EURO';
                    }
                    when 'US'{
                        qli.Billing_Currency__c = 'American Dollar';
                    }
                }
            }
 
            updateCustomerScoring(qli,relatedQuotes);
            //updateDealScoring(qli,relatedQuotes);
            copyCustomerGroup(qli,relatedQuotes, relatedBrands);
if(tube && qli.location__c == 'EU' )
 {
     if(relatedQuotes.get(qli.QuoteId).Count_Quote_line_item__c != null && relatedQuotes.get(qli.QuoteId).Count_Quote_line_item__c>0 )
     {
         System.debug('The QuoteID is '+qli.QuoteId +'The LAst is '+LastQuoteQLI.get(qli.QuoteId) );
        if(LastQuoteQLI.get(qli.QuoteId)!=null)
        CopyDealScoring(qli,LastQuoteQLI.get(qli.QuoteId));
     }else{
         updateDealScoring(qli,relatedQuotes);
     }
 }else{
     updateDealScoring(qli,relatedQuotes);
 }
        }
    }

    public static void setQliInformationBeforeUpdate(List<QuoteLineItem> newQuoteLineItems) {
        set<id> quotesIds = new set<id>();
        set<Id> productIds = new set<Id>();
        set<Id> brandIds = new set<Id>();
        for (QuoteLineItem qli:newQuoteLineItems){
            quotesIds.add(qli.QuoteId);
            productIds.add(qli.Product2Id);
            brandIds.add(qli.Brand__c);
        }

        map<Id , Quote>  relatedQuotes = new map<Id,Quote>( [select Id ,
                Opportunity.Account.Customer_Group__c, Opportunity.Account.Customer_Group__r.Name,
                Opportunity.AccountId,
                Opportunity.Account.Customer_Group__r.Id, Opportunity.Account.Name

        from Quote
        where Id IN : quotesIds] );

        map<Id, Brand__c> relatedBrands = new map<Id, Brand__c>([select Id, Name from Brand__c
        where Id IN: brandIds]);
        for (QuoteLineItem qli:newQuoteLineItems) {
            copyCustomerGroup(qli,relatedQuotes, relatedBrands);
        }

    }



    public static  void updateCustomerScoring(QuoteLineItem qli, map<Id, Quote> relatedQuotes){
        if (relatedQuotes.get(qli.QuoteId).Opportunity.Account.Customer_Type__c != null
                || relatedQuotes.get(qli.QuoteId).Brand_Positionning__c != null
                || relatedQuotes.get(qli.QuoteId).Opportunity.Account.Payment_terms__c != null
                || relatedQuotes.get(qli.QuoteId).Opportunity.Account.Business_at_other_product_line__c != null ){
            qli.Additional_comments_on_customer_scoring__c = relatedQuotes.get(qli.QuoteId).Opportunity.Account.Additional_comments_on_customer_scoring__c;
            qli.Brand_Positionning__c = relatedQuotes.get(qli.QuoteId).Brand_Positionning__c;
            qli.Business_at_other_product_line__c = relatedQuotes.get(qli.QuoteId).Opportunity.Account.Business_at_other_product_line__c;
            qli.Customer_EBB_rate__c = relatedQuotes.get(qli.QuoteId).Opportunity.Account.Customer_EBB_rate__c;
            qli.Customer_Type__c = relatedQuotes.get(qli.QuoteId).Opportunity.Account.Customer_Type__c;
            qli.Customer_end_of_year_rebate__c = relatedQuotes.get(qli.QuoteId).Opportunity.Account.Customer_end_of_year_rebate__c;
            qli.Monthly_overdue_DSO__c = relatedQuotes.get(qli.QuoteId).Opportunity.Account.Monthly_overdue_DSO__c;
            qli.Payment_terms__c = relatedQuotes.get(qli.QuoteId).Opportunity.Account.Payment_terms__c;
            qli.Quality_requirement__c = relatedQuotes.get(qli.QuoteId).Opportunity.Account.Quality_requirement__c;
            qli.Required_level_of_documentation__c = relatedQuotes.get(qli.QuoteId).Opportunity.Account.Required_level_of_documentation__c;

        }
    }

    public static  void updateDealScoring(QuoteLineItem qli, map<Id, Quote> relatedQuotes){
        qli.Brand_Positionning__c = relatedQuotes.get(qli.QuoteId).Brand_Positionning__c;
        qli.DS_Additionnal_comments_on_deal_scoring__c = relatedQuotes.get(qli.QuoteId).Additionnal_comments_on_deal_scoring__c;
        qli.DS_Albea_dependency_to_suppliers__c = relatedQuotes.get(qli.QuoteId).Alb_a_dependency_to_supplier_s__c;
        qli.DS_Contract_duration__c = relatedQuotes.get(qli.QuoteId).Contract_duration__c;
        qli.DS_Est_purchase_order_contract_duration__c = relatedQuotes.get(qli.QuoteId).Est_purchase_order_contract_duration__c;
        qli.DS_Exclusivity_Single_vs_Multiple_Supp__c = relatedQuotes.get(qli.QuoteId).Exclusivity_Single_vs_Multiple_Supplier__c;
        qli.DS_Indexation_of_raw_material_costs__c = relatedQuotes.get(qli.QuoteId).Indexation_of_raw_material_costs__c;
        qli.DS_Multiple_Release_Order_Blanket_Order__c = relatedQuotes.get(qli.QuoteId).Multiple_Release_Order_Blanket_Order__c;
        qli.DS_NB_month_of_stock_at_Albea_expenses__c = relatedQuotes.get(qli.QuoteId).of_month_of_stock_at_Alb_a_expenses__c;
        qli.DS_Non_stock_customer_requirements__c = relatedQuotes.get(qli.QuoteId).Non_stock_customer_requirements__c;
        qli.DS_Number_of_suppliers_for_customers__c = relatedQuotes.get(qli.QuoteId).Number_of_suppliers_for_customers__c;
        qli.DS_Penalties_customer_in_the_contract__c = relatedQuotes.get(qli.QuoteId).Penalties_for_the_customer_in_the_contra__c;
        qli.DS_Penalties_in_the_contract_for_Albea__c = relatedQuotes.get(qli.QuoteId).Penalties_in_the_contract_for_Alb_a__c;
        qli.DS_Skonto_for_cash_payment__c = relatedQuotes.get(qli.QuoteId).Skonto_for_cash_payment__c;
        qli.DS_Tooling_CAPEX_investment_required__c = relatedQuotes.get(qli.QuoteId).Tooling_CAPEX_investment_required__c;
        qli.DS_Tooling_CAPEX_investments_required__c = relatedQuotes.get(qli.QuoteId).Tooling_CAPEX_investments_required__c;
        qli.DS_Type_of_business__c = relatedQuotes.get(qli.QuoteId).Type_of_business__c;
    }
    public static  void CopyDealScoring(QuoteLineItem qli, QuoteLineItem lastQLI){
        qli.Deal_Scoring__c=lastQLI.Deal_Scoring__c;
        qli.Brand_Positionning__c = lastQLI.Brand_Positionning__c;
        qli.DS_Additionnal_comments_on_deal_scoring__c = lastQLI.DS_Additionnal_comments_on_deal_scoring__c;
        qli.DS_Albea_dependency_to_suppliers__c = lastQLI.DS_Albea_dependency_to_suppliers__c;
        qli.DS_Contract_duration__c = lastQLI.DS_Contract_duration__c;
        qli.DS_Est_purchase_order_contract_duration__c = lastQLI.DS_Est_purchase_order_contract_duration__c;
        qli.DS_Exclusivity_Single_vs_Multiple_Supp__c = lastQLI.DS_Exclusivity_Single_vs_Multiple_Supp__c;
        qli.DS_Indexation_of_raw_material_costs__c = lastQLI.DS_Indexation_of_raw_material_costs__c;
        qli.DS_Multiple_Release_Order_Blanket_Order__c = lastQLI.DS_Multiple_Release_Order_Blanket_Order__c;
        qli.DS_NB_month_of_stock_at_Albea_expenses__c = lastQLI.DS_NB_month_of_stock_at_Albea_expenses__c;
        qli.DS_Non_stock_customer_requirements__c = lastQLI.DS_Non_stock_customer_requirements__c;
        qli.DS_Number_of_suppliers_for_customers__c = lastQLI.DS_Number_of_suppliers_for_customers__c;
        qli.DS_Penalties_customer_in_the_contract__c = lastQLI.DS_Penalties_customer_in_the_contract__c;
        qli.DS_Penalties_in_the_contract_for_Albea__c = lastQLI.DS_Penalties_in_the_contract_for_Albea__c;
        qli.DS_Skonto_for_cash_payment__c = lastQLI.DS_Skonto_for_cash_payment__c;
        qli.DS_Tooling_CAPEX_investment_required__c = lastQLI.DS_Tooling_CAPEX_investment_required__c;
        qli.DS_Tooling_CAPEX_investments_required__c = lastQLI.DS_Tooling_CAPEX_investments_required__c;
        qli.DS_Type_of_business__c = lastQLI.DS_Type_of_business__c;
        qli.last_QLI_Payment_term__c=lastQLI.Payment_terms__c;
        //System.debug('The qli.Payment_terms__c is '+qli.Payment_terms__c+' ==> ' + lastQLI.Payment_terms__c);
    }
    public static  void copyCustomerGroup(QuoteLineItem qli, map<Id, Quote> relatedQuotes, map<Id,Brand__c> relatedBrands){
        String accountName;
        if (relatedQuotes.get(qli.QuoteId).Opportunity.Account.Customer_Group__c != null
                && relatedQuotes.get(qli.QuoteId).Opportunity.Account.Customer_Group__r.Name == 'WITHOUT GROUP'){
            qli.Tech_Account__c = relatedQuotes.get(qli.QuoteId).Opportunity.AccountId;
            accountName = relatedQuotes.get(qli.QuoteId).Opportunity.Account.Name;
        }else if (relatedQuotes.get(qli.QuoteId).Opportunity.Account.Customer_Group__c != null){
            qli.Tech_Customer_Group__c = relatedQuotes.get(qli.QuoteId).Opportunity.Account.Customer_Group__r.Id;
            accountName = relatedQuotes.get(qli.QuoteId).Opportunity.Account.Customer_Group__r.Name;
        }
        // Fill Brand To Be Added
        if (qli.Brand__c != null && qli.Tech_Account__c != null && relatedBrands.get(qli.Brand__c).Name == 'SAME AS ACCOUNT\'S NAME' ){
            qli.Product_Brand_Name_to_be_added__c = accountName;
        }
    }



}