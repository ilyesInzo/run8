/**
 * <b>Class CloneQuoteWizard :</b> the apex class need by the wizard quote
 * @author Eric Wartelle
 * @version 0.9 - To be tested
 * @history 0.9 - To be tested
 *          0.5 - Stub
 */
public with sharing class CloneQuoteWizard {
	// Attributs of the class CloneQuoteWizard
	public static String LOG_CLASS_NAME = 'CloneQuoteWizard';

	@AuraEnabled
	public static boolean displayCopyQuote(String recordId){
		boolean displayButton = false;
		Quote quote = [select id, Account.Account_status__c from Quote where Id = : recordId limit 1];
		system.Debug('display : quote found');
		if(quote.Account.Account_status__c == 'Active'){
			system.Debug('display : account active');
			String usrId = UserInfo.getUserId();
			String profileName = [Select Profile.Name from User Where id = : usrId limit 1].Profile.Name;
			if(profileName != 'Marketing' && profileName != 'Plant' && profileName.left(5) != 'Audit'){
				system.Debug('display : profile ok');
				if([Select id from QuoteLineItem Where QuoteId = : quote.id].size() <= 1){
					system.Debug('display : qlis <= 1');
					displayButton = true;
				}
			}
		}
		return displayButton;
	}




	// Methods of the class CloneQuoteWizard
	/**
	 * [ Description CloneQuoteOld : will run deep clone agent ]
	 * @param  String  [ quoteId                : the id of the quote we want to clone                ]
	 * @param  Boolean [ sameOpportunity        : do we want to use the same opportunity              ]
	 * @param  Boolean [ sameAccount            : do we want to use the same Account                  ]
	 * @param  String  [ OpportunityStageName   : the stage of the opportunity we want to create      ]
	 * @param  String  [ OpportunityQuoteType   : the quote type of the opportunity we want to create ]
	 * @param  String  [ OpportunityName        : the name of the opportunity we want to create       ]
	 * @param  String  [ OpportunityCloseDate   : the close date that we want to create               ]
	 * @param  String  [ OpportunityId          : the ID of another open opportunity                  ]
	 * @param  String  [ AccountID 			    : the ID of another valid account                     ]
	 * @param  Boolean [ useNewOpportunity      : do we use the informations for the new opportunity  ]
	 * @param  Boolean [ useSelectedOpportunity : do we need to use the selected opportunity          ]
	 * @param  Boolean [ useSelectedAccount     : do we need to use the selected account              ]
	 * @return String  [ the id of the cloned quote                                                   ]
	 */

	/*
   @AuraEnabled
   public static String CloneQuoteOld(String quoteId, Boolean sameOpportunity, Boolean sameAccount,
       String OpportunityStageName, String OpportunityQuoteType, String OpportunityName, String OpportunityCloseDate, String OpportunityId,
       String AccountId, Boolean useNewOpportunity, Boolean useSelectedOpportunity, Boolean useSelectedAccount ){

       System.Debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - CloneQuoteOld Start');

       Map<String, Schema.SObjectField> quotefields = Schema.getGlobalDescribe().get('Quote').getDescribe().fields.getMap();
       List<String> editableFields = new List<String>();
       for(Schema.SObjectField fieldRef : quotefields.values()) {
           Schema.DescribeFieldResult fieldResult = fieldRef.getDescribe();
           if(fieldResult.isCreateable()) {
               editableFields.add(fieldResult.getname());
           }
       }

       String query = 'Select ';
       for(String field : editableFields){
           query += field + ', ';
       }
       query += 'AccountId';
       //query = query.left(query.length()-2);
       query += ' FROM Quote WHERE Id =: quoteId';
       system.Debug('ici0 : ' + query);

       Quote quoteToClone = Database.query(query);

       //We're getting the clone quote
       /*Quote quoteToClone = [SELECT AccountId, Account_Code__c, AdditionalAddress, AdditionalCity, AdditionalCountry, AdditionalGeocodeAccuracy,
                                    AdditionalLatitude, AdditionalLongitude, AdditionalName, AdditionalPostalCode, AdditionalState, AdditionalStreet,
                                    Additionnal_comments_on_deal_scoring__c, Alb_a_dependency_to_supplier_s__c, BillingAddress, BillingCity, BillingCountry,
                                    BillingGeocodeAccuracy, BillingLatitude, BillingLongitude, BillingName, BillingPostalCode, BillingState, BillingStreet,
                                    Brand_Positionning__c, ContactId, Contact_Details__c, ContractId, Contract_duration__c,
                                    CreatedById, CreatedDate, Cross_Selling__c, Customer_Group__c, Customer__c, DataLoaderExtId__c, Date_Quote_for_Lost__c,
                                    Date_Quote_Killed_by_Albea__c, Date_Quote_Killed_By_Customer__c, Date_Quote_Presented__c, Date_Quote_Under_validation__c,
                                    date_Quote_Won__c, Date_Quote_Working_Document__c, Date_Quote__c, Deal_Scoring__c, Decision_date__c, Description, Discount,
                                    Email, Est_purchase_order_contract_duration__c, Exclusivity_Single_vs_Multiple_Supplier__c, ExpirationDate, Fax, First_Delivery_Date__c,
                                    General_deal_conditions__c, GrandTotal, Id, Indexation_Details__c, Indexation_of_raw_material_costs__c, Initial_Creation_date__c,
                                    IsDeleted, IsSyncing, Key_Sales_Area__c, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, LineItemCount,
                                    Main_compet_1__c, Main_compet_2__c, Market_Segment__c, Market_Sub_Segment__c, Mobile__c, Multiple_Release_Order_Blanket_Order__c,
                                    Name, Nombre_quote_item__c, Non_stock_customer_requirements__c, Number_of_suppliers_for_customers__c, of_month_of_stock_at_Alb_a_expenses__c,
                                    OpportunityId, OwnerId, Parent__c, Payment_terms_and_details__c, Payment_Terms_Details__c, Pa__c, Penalties_for_the_customer_in_the_contra__c,
                                    Penalties_in_the_contract_for_Alb_a__c, Phone,Picture_3D_Id__c, Picture__c, Pricebook2Id, Price_details__c, Pricing_Condition_Details__c,
                                    Product_Details__c, Project_TYpe__c, Quantity_Details__c, QuoteNumber, QuoteToAddress, QuoteToCity, QuoteToCountry, QuoteToGeocodeAccuracy,
                                    QuoteToLatitude, QuoteToName, QuoteToPostalCode, QuoteToState, QuoteToStreet, Quote_Due_Date__c, Quote_line_item_with_0__c,
                                    Raison_for_lost_on_won_quote__c, RecordTypeId, RFQ_Reception_Date__c, RFQ_Template_beauty_solution__c, RFQ_Template_CRP__c,
                                    RFQ_Template_Dispensing__c, RFQ_Template_Tube__c, RFQ_Template__c, Service_Details__c, ShippingAddress, ShippingCity, ShippingCountry,
                                    ShippingGeocodeAccuracy, ShippingHandling, ShippingLatitude, ShippingLongitude, ShippingName, ShippingPostalCode, ShippingState,
                                    ShippingStreet, Skonto_for_cash_payment__c, START_SYNC2__c, Status, Subtotal, Supply_Chain_Details__c, SystemModstamp, Tax,
                                    TBO_Comment__c, tech_error_process__c, Tech_SKP_KPI_Error__c, Tech_validation_error__c, Template_offer_Introduction__c,
                                    Tooling_CAPEX_investments_required__c, Tooling_CAPEX_investment_required__c, Tooling__c, TotalPrice, Total_Sales_Value_ks__c,
                                    Total_Sales__c, TOTAL_SCORING_SCORE__c, Tube_Cap_details__c, Type_of_business__c, Zephyr_ID__c
                               FROM Quote
                              WHERE Id =: quoteId];

       AP002_QuoteDeepCloneAgent quoteDeepCloneAgent = new AP002_QuoteDeepCloneAgent(quoteToClone, sameAccount, sameOpportunity,
       OpportunityStageName, OpportunityQuoteType, OpportunityName, OpportunityCloseDate, OpportunityId,
       AccountId, useNewOpportunity, useSelectedOpportunity, useSelectedAccount);

       //Storing a save point for database and rolling back in case of error
       System.Savepoint copySavePoint;

       try{
           copySavePoint = Database.setSavepoint();
           quoteDeepCloneAgent.cloneAction();
       }
       catch(Exception e){
           Database.rollback(copySavePoint);
           throw e;
       }

       System.Debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - CloneQuoteOld Stop');

       return quoteDeepCloneAgent.clonedObject.id;
   }
   */
	/**
	 * [ Description cloneQuote : will run deep clone agent ]
	 * @param  String  [ quoteId                : the id of the quote we want to clone                ]
	 * @param  String  [ OpportunityStageName   : the stage of the opportunity we want to create      ]
	 * @param  String  [ OpportunityQuoteType   : the quote type of the opportunity we want to create ]
	 * @param  String  [ OpportunityName        : the name of the opportunity we want to create       ]
	 * @param  String  [ OpportunityCloseDate   : the close date that we want to create               ]
	 * @param  String  [ OpportunityId          : the ID of another open opportunity                  ]
	 * @param  String  [ AccountID 			   : the ID of another valid account                      ]
	 * @return String  [ the id of the cloned quote                                                   ]
	 */
	@AuraEnabled
	public static String CloneQuote(String quoteId, String OpportunityStageName, String OpportunityQuoteType,
			String OpportunityName, String OpportunityCloseDate, String OpportunityId, String AccountId){

		System.Debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - CloneQuote Start');
		System.Debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - AccountId : ' + AccountId);

		//BypassPB
		String usrId = UserInfo.getUserId();
		User usr = [Select Bypass_Process_Builder__c, Profile.Name, Bypass_trigger__c from User where id = :usrId limit 1];
		String oldBypasses = usr.Bypass_Process_Builder__c;

		if(usr.Bypass_Process_Builder__c == null || usr.Bypass_Process_Builder__c == ''){
			usr.Bypass_Process_Builder__c = 'Copy customer scoring to Account';
		}
		else{
			usr.Bypass_Process_Builder__c += ';Copy customer scoring to Account';
		}

		update usr;
		system.debug('User Bypass PB ' + usr.Bypass_Process_Builder__c);

		//We're getting the clone quote

		Map<String, Schema.SObjectField> quotefields = Schema.getGlobalDescribe().get('Quote').getDescribe().fields.getMap();
		List<String> editableFields = new List<String>();
		for(Schema.SObjectField fieldRef : quotefields.values()) {
			Schema.DescribeFieldResult fieldResult = fieldRef.getDescribe();
			if(fieldResult.isCreateable()) {
				editableFields.add(fieldResult.getname());
			}
		}

		String query = 'Select ';
		for(String field : editableFields){
			query += field + ', ';
		}
		query += 'AccountId';
		//query = query.left(query.length()-2);
		query += ' FROM Quote WHERE Id =: quoteId';
		system.Debug('ici0 : ' + query);

		Quote quoteToClone = Database.query(query);

		/*Quote quoteToClone = [SELECT AccountId, Account_Code__c, AdditionalAddress, AdditionalCity, AdditionalCountry, AdditionalGeocodeAccuracy,
									 AdditionalLatitude, AdditionalLongitude, AdditionalName, AdditionalPostalCode, AdditionalState, AdditionalStreet,
									 Additionnal_comments_on_deal_scoring__c, Alb_a_dependency_to_supplier_s__c, BillingAddress, BillingCity, BillingCountry,
									 BillingGeocodeAccuracy, BillingLatitude, BillingLongitude, BillingName, BillingPostalCode, BillingState, BillingStreet,
									 Brand_Positionning__c, ContactId, Contact_Details__c, ContractId, Contract_duration__c,
									 CreatedById, CreatedDate, Cross_Selling__c, Customer_Group__c, Customer__c, DataLoaderExtId__c, Date_Quote_for_Lost__c,
									 Date_Quote_Killed_by_Albea__c, Date_Quote_Killed_By_Customer__c, Date_Quote_Presented__c, Date_Quote_Under_validation__c,
									 date_Quote_Won__c, Date_Quote_Working_Document__c, Date_Quote__c, Deal_Scoring__c, Decision_date__c, Description, Discount,
									 Email, Est_purchase_order_contract_duration__c, Exclusivity_Single_vs_Multiple_Supplier__c, ExpirationDate, Fax, First_Delivery_Date__c,
									 General_deal_conditions__c, GrandTotal, Id, Indexation_Details__c, Indexation_of_raw_material_costs__c, Initial_Creation_date__c,
									 IsSyncing, Key_Sales_Area__c, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, LineItemCount,
									 Main_compet_1__c, Main_compet_2__c, Market_Segment__c, Market_Sub_Segment__c, Mobile__c, Multiple_Release_Order_Blanket_Order__c,
									 Name, Nombre_quote_item__c, Non_stock_customer_requirements__c, Number_of_suppliers_for_customers__c, of_month_of_stock_at_Alb_a_expenses__c,
									 OpportunityId, OwnerId, Parent__c, Payment_terms_and_details__c, Payment_Terms_Details__c, Pa__c, Penalties_for_the_customer_in_the_contra__c,
									 Penalties_in_the_contract_for_Alb_a__c, Phone,Picture_3D_Id__c, Picture__c, Pricebook2Id, Price_details__c, Pricing_Condition_Details__c,
									 Product_Details__c, Project_TYpe__c, Quantity_Details__c, QuoteNumber, QuoteToAddress, QuoteToCity, QuoteToCountry, QuoteToGeocodeAccuracy,
									 QuoteToLatitude, QuoteToName, QuoteToPostalCode, QuoteToState, QuoteToStreet, Quote_Due_Date__c, Quote_line_item_with_0__c,
									 Raison_for_lost_on_won_quote__c, RecordTypeId, RFQ_Reception_Date__c, RFQ_Template_beauty_solution__c, RFQ_Template_CRP__c,
									 RFQ_Template_Dispensing__c, RFQ_Template_Tube__c, RFQ_Template__c, Service_Details__c, ShippingAddress, ShippingCity, ShippingCountry,
									 ShippingGeocodeAccuracy, ShippingHandling, ShippingLatitude, ShippingLongitude, ShippingName, ShippingPostalCode, ShippingState,
									 ShippingStreet, Skonto_for_cash_payment__c, START_SYNC2__c, Status, Subtotal, Supply_Chain_Details__c, SystemModstamp, Tax,
									 TBO_Comment__c, tech_error_process__c, Tech_SKP_KPI_Error__c, Tech_validation_error__c, Template_offer_Introduction__c,
									 Tooling_CAPEX_investments_required__c, Tooling_CAPEX_investment_required__c, Tooling__c, TotalPrice, Total_Sales_Value_ks__c,
									 Total_Sales__c, TOTAL_SCORING_SCORE__c, Tube_Cap_details__c, Type_of_business__c, Zephyr_ID__c
							    FROM Quote
							   WHERE Id =: quoteId];*/

		system.debug('ici : ' + quoteToClone.AccountId);
		AP002_QuoteDeepCloneAgent quoteDeepCloneAgent = new AP002_QuoteDeepCloneAgent(quoteToClone,
				CloneQuoteWizard.useSameAccount(accountId),
				CloneQuoteWizard.useSameOpportunity(OpportunityStageName, OpportunityQuoteType, OpportunityName,
						OpportunityCloseDate, OpportunityId),
				OpportunityStageName,
				OpportunityQuoteType,
				OpportunityName,
				OpportunityCloseDate,
				OpportunityId,
				AccountId,
				CloneQuoteWizard.useNewOpportunity(OpportunityStageName, OpportunityQuoteType,
						OpportunityName, OpportunityCloseDate),
				CloneQuoteWizard.useSelectedOpportunity(OpportunityId),
				! CloneQuoteWizard.useSameAccount(accountId)
		);


		//Storing a save point for database and rolling back in case of error
		System.Savepoint copySavePoint;

		try{
			copySavePoint = Database.setSavepoint();
			quoteDeepCloneAgent.cloneAction();
		}
		catch(Exception e){
			Database.rollback(copySavePoint);
			throw e;
		}

		//Reset Bypass PB
		usr.Bypass_Process_Builder__c = oldBypasses;
		
		update usr;

		System.Debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - CloneQuote Stop');
//		LC02_CalculateGamificationPoints.calculatePoints(AP00_UtilityConstants.BADGE_QUOTE_COPY);
		return quoteDeepCloneAgent.clonedObject.id;
	}

	/**
	 * [ isQuoteWon description : indicate if the quote is won or not ]
	 * @param  String [ quoteId : the id of the quote we want to test ]
	 * @return boolean
	 */
	@AuraEnabled
	public static Boolean isQuoteWon(String quoteId){
		//ALE : en plus on check désormais si l'opportunité est closed
		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - isQuoteWon Start');

		Quote concernQuote = [SELECT Status, Opportunity.StageName FROM Quote WHERE Id =: quoteId];

		Boolean retour = concernQuote.Status == 'Won' || (concernQuote.Opportunity.StageName.left(6) == 'Closed');

		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - isQuoteWon Stop');

		return retour;
	}

	/**
	 * [ getContract description : ]
	 */
	@AuraEnabled
	public static Opportunity getNewOpportunity(String quoteId){
		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getContract Start');

		Quote concernQuote = [SELECT Status, AccountId FROM Quote WHERE Id =: quoteId];

		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - getContract Stop');

		return new Opportunity(AccountID = concernQuote.AccountID);
	}

	/**
	 * [ useSameAccount description : indicate if we want to use the same account ]
	 * @param  String [ accountId : id of an account ]
	 * @return Boolean
	 */
	public static Boolean useSameAccount(String accountId){
		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - useSameAccount Start');

		Boolean result = accountId == '' || accountId == null;

		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - result : ' + result );

		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - useSameAccount Stop');

		return result;
	}

	/**
	 * [ useSameOpportunity description : indicate if we want to use the same opportunity ]
	 * @param  String  [ OpportunityStageName : the stage name of the new opportunity in case we want to create one ]
	 * @param  String  [ OpportunityQuoteType : the quote type of the new opportunity in case we want to create one ]
	 * @param  String  [ OpportunityName      : the name of the new opportunity in case we want to create one       ]
	 * @param  String  [ OpportunityCloseDate : the close date of the new opportunity in case we want to create one ]
	 * @param  String  [ OpportunityId        : the id of an existing opportunity if we want to use it              ]
	 * @return Boolean 
	 */
	public static Boolean useSameOpportunity(String OpportunityStageName,
			String OpportunityQuoteType, String OpportunityName,
			String OpportunityCloseDate, String OpportunityId){
		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - useSameOpportunity Start');

		Boolean result = (OpportunityStageName == null || OpportunityStageName == '') &&
				(OpportunityQuoteType == null || OpportunityQuoteType == '') &&
				(OpportunityName == null || OpportunityName == '') &&
				(OpportunityCloseDate == null || OpportunityCloseDate == '') &&
				(OpportunityId == null || OpportunityId == '');

		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - result : ' + result );

		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - useSameOpportunity Stop');

		return result;
	}

	/**
	 * [ useNewOpportunity description : indicate if we want to use the new opportunity ]
	 * @param  String  [ OpportunityStageName : the stage name of the new opportunity that we want to create ]
	 * @param  String  [ OpportunityQuoteType : the quote type of the new opportunity that we want to create ]
	 * @param  String  [ OpportunityName      : the name of the the new opportunity that we want to create   ]
	 * @param  String  [ OpportunityCloseDate : the close date of the new opportunity that we want to create ]
	 * @return Boolean
	 */
	public static Boolean useNewOpportunity(String OpportunityStageName,
			String OpportunityQuoteType, String OpportunityName,
			String OpportunityCloseDate){
		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - useNewOpportunity Start');

		Boolean result = (OpportunityStageName != null && OpportunityStageName != '') &&
				(OpportunityQuoteType != null && OpportunityQuoteType != '') &&
				(OpportunityName != null && OpportunityName != '') &&
				(OpportunityCloseDate != null && OpportunityCloseDate != '');

		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - result : ' + result );

		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - useNewOpportunity Stop');

		return result;
	}

	/**
	 * [ useExistingOpportunity description : indicate if we want to use the selected opportunity ]
	 * @param  String  [ OpportunityID : the id of the existing opportunity that we want to use ]
	 * @return Boolean 
	 */
	public static Boolean useSelectedOpportunity(String OpportunityId){
		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - useExistignOpportunity Start');

		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - (OpportunityId != null) : ' + (OpportunityId != null && OpportunityId != ''));

		System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - useExistignOpportunity Stop');

		return (OpportunityId != null && OpportunityId != '');
	}
}