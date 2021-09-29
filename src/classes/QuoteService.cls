/**
* @description Service class for interacting with Quote
* @author MDK
* @date 07/11/2017
*/
public abstract class QuoteService {

   	Private static final String pmEligibleSubSeg = Label.Label_PM_Eligible_ProductSubSegment;

	//Added by Thanina ************
	Private static final String authoProfilesIDToDelQLI = Label.Auth_Profile_Delete;

	/**
     * @description getQuotesInfo : fetch quote values for each quoteId]
     * @param quoteIds
     * @return quotesById [quoteId => Quote]
     */
    public static Map<Id, Quote> getQuotesInfo(Set<Id> quoteIds) {

        Map<Id, Quote> quotesById = new Map<Id, Quote>([
        		Select 	id,
                        Name,
						Brand_Positionning__c,
						Of_month_of_stock_at_Alb_a_expenses__c,
                    	Contract_duration__c,
                    	Indexation_of_raw_material_costs__c,
                    	Exclusivity_Single_vs_Multiple_Supplier__c,
                    	Tooling_CAPEX_investments_required__c,
	                    Alb_a_dependency_to_supplier_s__c,
	                    Penalties_for_the_customer_in_the_contra__c,
	                    Type_of_business__c, 
	                    Penalties_in_the_contract_for_Alb_a__c, 
	                    Multiple_Release_Order_Blanket_Order__c,
	                    Skonto_for_cash_payment__c, 
	                    Additionnal_comments_on_deal_scoring__c, 
	                    Tooling_CAPEX_investment_required__c,
	                    Est_purchase_order_contract_duration__c, 
	                    Number_of_suppliers_for_customers__c,
	                    Non_stock_customer_requirements__c,
	                    Opportunity.Account.Country__r.Country_Code__c,
	                    Project_Type__c,
	                    Tech_SKP_KPI_Error__c
				From Quote 
				Where Id In :quoteIds
            ]
        );
            
        return quotesById;

    }


   	/**
     * @description getQuoteLineItemsInfo : fetch Quote Line Item values for each quoteId]
     * @param quoteIds
     * @return quoteLineItemsByQuoteId [quoteId => Quote]
     */
    public static Map<Id, List<QuoteLineItem>> getQuoteLineItemsInfo(Set<Id> quoteIds) {

        List<QuoteLineItem> quoteLineItems= new List<QuoteLineItem>([
				Select 	id,
						QuoteId,
                        Quantity, 
						T_Quote_status__c,
						Production_Plant__c, 
						Production_Cluster__c,
						Product_Line__c,
						Unitprice ,
						All_KPIs_OK__c,
						Price_book_level_per_1000__c,
						isPriceMatrix__c,
						Product_Sub_segment__c
    			From QuoteLineItem 
    			Where QuoteId in :quoteIds
            ]
        );
        
        Map<Id, List<QuoteLineItem>> quoteLineItemsByQuoteId = SObjectUtils.toMapOfListById(quoteLineItems,'QuoteId');    
        return quoteLineItemsByQuoteId;

    }

    /**
     * @description set Quote values before the Insert or Update
     * @param newQuotes : trigger.new
     * @return nothing
     */
    public static void setQuotes(List<Quote> newQuotes) {

    	map<Id, list<QuoteLineItem>> quoteLineItemsByQuoteId = getQuoteLineItemsInfo(SObjectUtils.toSetOfId(newQuotes));	
			
    	//update the qli's statuses
        if (!quoteLineItemsByQuoteId.isEmpty()) {
            for(Quote qte : newQuotes){
            	Boolean TechError = false;
                //Added By Achraf LAMZABI : Add Simulation Status in the condition
                if( qte.Status != 'Draft' && qte.Status != 'Simulation' && qte.Status != 'Killed By Customer' && qte.Status != 'Killed By Albea' ){//&& qte.Status != 'Killed By Customer' && qte.Status != 'Killed By Albea' ==>Commented ticket 2456
                    for(QuoteLineItem item : quoteLineItemsByQuoteId.get(qte.id) ){
                        System.debug('QuoteService.setQuotes : item.production_plant__c'+item.production_plant__c); 
                        System.debug('QuoteService.setQuotes : item.Production_Cluster__c'+item.Production_Cluster__c);                         
                        if( String.isBlank(item.production_plant__c) || String.isBlank(item.Production_Cluster__c)){
                            TechError = TechError || true;        
                        	System.debug('------ERROR');                         
                        } else  {
                            TechError = TechError || false;
                        	System.debug('------ NO ERROR');                         
                        }                  
                    }
                	System.debug(TechError);
                	if(TechError){
                        qte.tech_error_process__c = 'ERROR';
                    	System.debug('------ERROR');                 		
                	} else {
                        qte.tech_error_process__c = '';
                    	System.debug('------ NO ERROR');                 		
                	}                                
                }//end if status != draft    
                else{
                	qte.tech_error_process__c = '';	
                }        
            }//end bulk   
        }	
	}
	
	 /**
     * @description checkKPIs before changing the status of the Quote
     * @param newQuotes : trigger.new
     * @return nothing
     */
    public static void checkKPIs(List<Quote> newQuotes) {

    	map<Id, list<QuoteLineItem>> quoteLineItemsByQuoteId = getQuoteLineItemsInfo(SObjectUtils.toSetOfId(newQuotes));	
			
    	//update the qli's statuses
        if (!quoteLineItemsByQuoteId.isEmpty()) {
        	
            for(Quote qte : newQuotes){
            	Boolean kPIError = false;
                if( qte.Status == 'Presented' || qte.Status == 'Won' || qte.Status == 'Lost'){
                    for(QuoteLineItem item : quoteLineItemsByQuoteId.get(qte.id) ){
                         if( item.All_KPIs_OK__c == false  
                         && item.ispricematrix__c
                         &&  item.Price_book_level_per_1000__c != -1 ){//dont trigger error if it is a specific price
                            kPIError = true;  
                         }
                    }//end for qlis
                  
                  //if at least one Qli is incomplete==> raise an error
                  qte.Tech_SKP_KPI_Error__c = kPIError;                    
                           
                }//end if status                  
                         
            }//end bulk   
        }	
	}
	
	
		 /**
     * @description check the quote's project type and update the isProcematrix field of the quoteLineItems
     * @param newMapQuotes : trigger.newMap & oldMapQuotes : trigger.oldMap
     * @return nothing
     * ticket 2741
     */
    public static void checkCLIisPricematrix( Map<Id, Quote> newMapQuotes , Map<Id, Quote> oldMapQuotes ) {
    	
        List<Quotelineitem> liQlisToUpdate = new list<quotelineitem>();   	
    	map<string,Boolean> accessMapPM = QuoteLineItemService.mapAccessToPM();
    	map<Id, list<QuoteLineItem>> quoteLineItemsByQuoteId = getQuoteLineItemsInfo(SObjectUtils.toSetOfId(newMapQuotes.values()));
    	map<Id, Quote> quotesById =	getQuotesInfo(newMapQuotes.keySet()); 		

		for(Quote qte : newMapQuotes.values()){
			if(qte.Project_TYpe__c != oldMapQuotes.get(qte.id).Project_TYpe__c) {
				
				String quoteCountry = quotesById.get(qte.id).Opportunity.Account.Country__r.Country_Code__c;
			  	
                if(quoteLineItemsByQuoteId.containsKey(qte.id) ){
			  		for(QuoteLineItem qli : quoteLineItemsByQuoteId.get(qte.id) ){                    	
                		string key = quoteCountry+'_'+qli.product_line__c+'_'+  qte.Project_Type__c;
		            	if(pmEligibleSubSeg.contains(qli.Product_Sub_segment__c))
		            		qli.isPriceMatrix__c =  accessMapPM.get(key) != null  ? accessMapPM.get(key) :false;
		            		liQlisToUpdate.add(qli);
                	}
            	}
			}
		}		
		update liQlisToUpdate;
	}
    
    
    public static void checkEditSimulationStatus( List<Quote> newQuotes , Map<Id, Quote> oldMapQuotes ) {
        
        if (!authoProfilesIDToDelQLI.contains(UserInfo.getProfileId())) {
			for (Quote qli : newQuotes) 
            {
                if(qli.status != 'Simulation' && oldMapQuotes.containsKey(qli.id) && oldMapQuotes.get(qli.id).status == 'Simulation'){
                    if( qli.TECH_EditSimulationStatus__c == false ){
                		qli.addError(Label.MSG_QuoteChangeSimulationStatus);
                	}
                	else{
                    	qli.TECH_EditSimulationStatus__c = false;
                	}
            	}		
			}
        }
        
    }

	// Check if the connected user can Delete QLI

	public static void checkCanDeleteQuote(List<Quote> listQuotes) {

		if (!authoProfilesIDToDelQLI.contains(UserInfo.getProfileId())) {
			for (Quote qli : listQuotes) 
            {
                if(qli.status != 'Simulation' || qli.TECH_DeleteSimulation__c == false){
                	qli.addError(Label.Delete_Quote_Msg);
                }
            }		
		}
	}
	
	
	
}