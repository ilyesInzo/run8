/**
 * [Class AP002_QuoteDeepCloneAgent : will manage the clone for the quote]
 * @author EWA, King Arthur
 * @version 0.9.9 - Insert call to be done at another level
 * @history 0.9.9 - Insert call to be done at another level
 *          0.9   - To be tested
 *          0.5   - Stub
 */
public class AP002_QuoteDeepCloneAgent extends APXXX_VirtualDeepCloneAgent {
	//Attributs for the class AP002_QuoteDeepCloneAgent 
    private static String LOG_CLASS_NAME = 'AP002_QuoteDeepCloneAgent';
    
    /**
     * [sameAccountFlag description : will tell if we need to use the same account]*
     */
    public Boolean sameAccountFlag;
    
    /**
     * [sameOpportunityFlag description : will tell if we need to use the same opportunity]
     */
    public Boolean sameOpportunityFlag;

    /**
     * [opportunityStageName description : the Stage of a newly created Opportunity]
     */
    public String opportunityStageName;

    /**
     * [opportunityQuoteType description : the quote type of a newly create Opportunity]
     */
    public String opportunityQuoteType;

    /**
     * [opportunityName description : the name of the newly created Opportunity]
     */
    public String opportunityName;

    /**
     * [opportunityCloseDate description : the close date of the newly create Opportunity]
     */
    public String opportunityCloseDate;

    /**
     * [opportunityId description : the Id of the selected Opportunity]
     */
    public String opportunityId;

    /**
     * [accountId description : the Id of the selected account]
     */
    public String accountId;
    
    /**
     * [useNewOpportunity description : a flag to show if we're going to use a new Opportunity]
     */
    public Boolean useNewOpportunity;

    /**
     * [useSelectedOpportunity description : a flag to show if we're going to use the selected Opportunity]
     */
    public Boolean useSelectedOpportunity;

    /**
     * [useSelectedAccount description : a flag to show if we're going to use the selected Account]
     */
    public Boolean useSelectedAccount;

    /**
     * [pmMOQPrices description : will store the PM_MOQ_Price__c linked to the QOL ]
     */ 
    public List<PM_MOQ_price__c> pmMOQPrices;

    /**
     * [pmPriceDetails description : will store PM_Price_Detail__c linked to the QOL ]
     */
    public List<PM_Price_Detail__c> pmPriceDetails;

    /**
     * [pmPriceRecommendations description : will store PM_Price_Recommendation__c linked to the QOL ]
     */
    public List<PM_Price_Recommendation__c> pmPriceRecommendations;

    /**
     * [pmReviewNetPriceperMOQs description : will store PM_Review_NetPrice_per_MOQ__c linked to the QOL]
     */
    //Commented 26/11 ALE
    //public List<PM_Review_NetPrice_per_MOQ__c> pmReviewNetPriceperMOQs;

    /**
     * [pmSelectedDispensingConfigs description : will store PM_Selected_Dipsensing_config__c linked to the QOL ]
     */ 
    public List<PM_Selected_Dipsensing_config__c> pmSelectedDispensingConfigs;

    /**
     * [pmSelectedTubesConfigs description : will store PM_Selected_Tubes_Config__c linked to the QOL ]
     */
    public List<PM_Selected_Tubes_Config__c> pmSelectedTubesConfigs;

    /**
     * [pmSelectedServiceTubesConfigs description : will store PM_Selected_Service_Tubes_Config__c linked to the QOL ] 
     */ 
    public List<PM_Selected_Service_Tubes_Config__c> pmSelectedServiceTubesConfigs;

    /**
     * [quoteLineItemDeepClones description : a list of deep clone agent for the Quote Line Item ]
     */
    public List<AP002_QuoteLineItemDeepCloneAgent> quoteLineItemDeepCloneAgents = new List<AP002_QuoteLineItemDeepCloneAgent>();
    
    //Constructors for the class AP002_QuoteDeepCloneAgent
    /**
     * [Constructor of the class AP002_QuoteDeepCloneAgent]
     * @param Quote   [ quoteToClone           : the clone we want to clone                                                       ]
     * @param Boolean [ sameAccountFlag        : will tell if we need to use the same account                                     ]
     * @param Boolean [ sameOpportunityFlag    : will tell if we need to use the same opportunity                                 ]
     * @param String  [ opportunityStageName   : the stage for the new Opportunity if we want to create a new opportunity         ]
     * @param String  [ opportunityQuoteType   : the type of quote for the new Opportunity if we want to create a new opportunity ]
     * @param String  [ opportunityName        : the name of the new Opportunity if we want to create a new opportunity           ]
     * @param String  [ opportunityCloseDate   : the close date of the new Opportunity if we want to create a new opportunity     ]
     * @param String  [ opportunityId          : the id of another open Opportunity if we want to use it                          ]
     * @param String  [ accountId              : the id of another Account if we want to use it                                   ]
     * @param Boolean [ useNewOpportunity      : a flag to indicate if we use a new Opportunity                                   ]
     * @param Boolean [ useSelectedOpportunity : a flag to indicate if we use an existing Opportunity                             ]
     * @param Boolean [ useSelectedAccount     : a flag to indicate if we use the selected Account                                ]
     */
    public AP002_QuoteDeepCloneAgent(Quote quoteToClone, Boolean sameAccountFlag, Boolean sameOpportunityFlag,
        String opportunityStageName, String opportunityQuoteType, String opportunityName, String opportunityCloseDate, String opportunityId,
        String accountId, Boolean useNewOpportunity, Boolean useSelectedOpportunity, Boolean useSelectedAccount){
    	super(quoteToClone);
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor start');
    	
    	this.sameAccountFlag = sameAccountFlag;
    	this.sameOpportunityFlag = sameOpportunityFlag;
        this.opportunityStageName = opportunityStageName;
        this.opportunityQuoteType = opportunityQuoteType;
        this.opportunityName = opportunityName;
        this.opportunityId = opportunityId;
        this.accountId = accountId;
        this.useNewOpportunity = useNewOpportunity;
        this.useSelectedOpportunity = useSelectedOpportunity;
        this.useSelectedAccount = useSelectedAccount;
        this.opportunityCloseDate = opportunityCloseDate;
    	   
        this.initializeCloneAgent();

    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Constructor stop');
    }
    
    //Methods of the class AP002_QuoteDeepCloneAgent
    /**
     * [Method initializeCloneAgent : we're going to initialize the quote line item that we want to clone ]
     */
    public void initializeCloneAgent(){
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializeCloneAgent Start');

        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - this.sameAccountFlag : ' + this.sameAccountFlag);
        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - this.sameOpportunityFlag : ' + this.sameOpportunityFlag);
        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - this.opportunityStageName : ' + this.opportunityStageName);
        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - this.opportunityQuoteType : ' + this.opportunityQuoteType);
        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - this.opportunityName : ' + this.opportunityName);
        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - this.opportunityId : ' + this.opportunityId);
        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - this.accountId : ' + this.accountId);
        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - this.useNewOpportunity : ' + this.useNewOpportunity);
        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - this.useSelectedOpportunity : ' + this.useSelectedOpportunity);
        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - this.useSelectedAccount : ' + this.useSelectedAccount);
        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - this.opportunityCloseDate : ' + this.opportunityCloseDate);
        
    	//We need to get all the Quote Line Item linked to the concerned quote

        Map<String, Schema.SObjectField> qlifields = Schema.getGlobalDescribe().get('QuoteLineItem').getDescribe().fields.getMap();
        List<String> editableFields = new List<String>();
        for(Schema.SObjectField fieldRef : qlifields.values()) {
            Schema.DescribeFieldResult fieldResult = fieldRef.getDescribe();
            if(fieldResult.isCreateable()) {
                editableFields.add(fieldResult.getname());
            }
        }

        String query = 'Select ';
        for(String field : editableFields){
            query += field + ', ';
        }
        query = query.left(query.length()-2);
        String idquote = this.objectToClone.Id;
        query += ' FROM QuoteLineItem WHERE QuoteId =: idquote';
        List<QuoteLineItem> qliLst = new List<QuoteLineItem>();
        qliLst = Database.query(query);
        Map<Id, QuoteLineItem> qlis =   new Map<Id, QuoteLineItem>(qliLst);
        system.Debug('les qlis : ' + qlis);
        /*
    	Map<Id, QuoteLineItem> qlis = 
                    new Map<Id, QuoteLineItem>([SELECT Account_Name__c, Actuator_Type__c, Actuator__c, Actuor_Type__c, 
    	                                                Additional_comments_on_customer_scoring__c, Additionnal_comments_on_service_scoring__c,
    	                                                ALBEA_CAPEX_needed_k_Cur__c, ALBEA_CAPEX_needed_k__c, Annual_Volume__c, Attachment__c,
    	                                                Avg_nb_of_plate_print_color_changes_max__c, Based_on_Alb_a_Concept__c, Below_MOQs__c,
    	                                                Billing_Currency_Position__c, Billing_Currency_Rate__c, Billing_Currency_Symbol__c,
    	                                                Billing_Currency__c, Body_Material__c, Bottle_neck__c, Brand_Positionning__c,
    	                                                Business_at_other_product_line__c, Bypass_VR__c, C0_C1_per_1000_Cur__c, Cap_decoration__c,
    	                                                Cap_Peel_Seal__c, Cap__c, CB0__c, CB1_Kcur__c, CB1__c, CBO_K_Cur__c, Color_matching_process__c,
    	                                                Color__c, Combo__c, Comments__c, Comment_On_Product_Confirguration__c, Compatibility_Tests__c,
    	                                                Competitor_price_per_1000_Cur__c, Competitor_price_per_1000__c, Contract_Duration_Y__c,
    	                                                Contract_Yes_No__c, copy_quote_status__c, CreatedById, CreatedDate,
    	                                                Customer_Country__c, Customer_EBB_rate__c, Customer_end_of_year_rebate__c, Customer_Scoring__c,
    	                                                Customer_Size__c, Customer_Type__c, DataLoaderExtId__c, Deal_and_Context_Comments__c, 
    	                                                Deal_Scoring__c, Decoration_development__c, Delta_vs_list_price__c, Description, Description__c,
    	                                                Diameter_inches__c, Diameter_mm__c, Diameter__c, Diptube_Material__c, Discount,
    	                                                Dispensing_family__c, Dosage__c, Dose__c, Dressing__c,
    	                                                DS_Additionnal_comments_on_deal_scoring__c, DS_Albea_dependency_to_suppliers__c,
    	                                                DS_Contract_duration__c, DS_Est_purchase_order_contract_duration__c,
    	                                                DS_Exclusivity_Single_vs_Multiple_Supp__c, DS_Indexation_of_raw_material_costs__c,
    	                                                DS_Multiple_Release_Order_Blanket_Order__c, DS_NB_month_of_stock_at_Albea_expenses__c,
    	                                                DS_Non_stock_customer_requirements__c, DS_Number_of_suppliers_for_customers__c,
    	                                                DS_Penalties_customer_in_the_contract__c, DS_Penalties_in_the_contract_for_Albea__c,
    	                                                DS_Skonto_for_cash_payment__c, DS_Tooling_CAPEX_investments_required__c,
    	                                                DS_Tooling_CAPEX_investment_required__c, DS_Type_of_business__c, Engine__c, 
    	                                                EU_rate_to_currency__c, Finish__c, Fitting_Method__c, Fixation__c, General_Comment__c,
    	                                                Head_Aspect__c, Head_Color__c, Head__c, Hot_Stamp__c, Id, ID_18_quote_item__c, ID_Calculette__c,
    	                                                Incoterms_Days__c, Incoterms__c, Incoterm__c, Initial_Creation_date__c, Innovation__c,
    	                                                Insert_Coloring_SA__c, Invoicing_cluster_contribution_k_Cur__c, Invoicing_cluster_contribution__c,
    	                                                Invoicing_Cluster__c, Invoicing_Plant__c, isPriceMatrix__c, Item_name__c, LastModifiedById,
    	                                                LastModifiedDate, LineNumber, ListPrice, Location__c, Main_Competitor_1_del__c, MAJ_Opportunity__c,
    	                                                Manufacturing_CB1_k__c, Manufacturing_Sales_Value_per_1000_Cur__c, Market_Of_Application__c,
    	                                                Market_Segment__c, Market_Sub_Segment__c, Material__c, Max_nb_of_ref_per_run__c, 
    	                                                Minimum_Order_Quantity__c, Minimum_per_artwork_nb_tubes__c, Monthly_overdue_DSO__c, Neck_Finish__c,
    	                                                Neck__c, Non_standard_supply_chain_process__c, of_Flexo_colors__c, of_Offset_colors__c, of_SS_colors__c,
    	                                                Opportunity_Name__c, Opp_total_sales_value__c, Other_printing_effects__c,
    	                                                Other__c, Ouptut__c, Pack_type__c, Payment_terms_PLT__c, Payment_terms_PUT__c, Payment_terms__c,
    	                                                PCcur__c, Peel_Seal__c, PE_Bag__c, Platts_level__c, Platt_Level__c, PM_Product_Hierarchy__c,
    	                                                PPM_Reference__c, Preproduction__c, PricebookEntryId, Price_book_level_per_1000_dollar__c,
    	                                                Price_book_level_per_1000__c, Price_Book__c, Printing_type__c, Process_validation_img__c,
    	                                                Product2Id, Production_Cluster__c, Production_Plant__c, Product_Contribution_k__c,
    	                                                Product_Customization__c, Product_Final_Look_image__c, Product_Final_Look__c, Product_Hierarchy__c,
    	                                                Product_Line__c, Product_Name__c, Product_sales_Value_en_K_Cur__c, Product_Sales_value_k__c,
    	                                                Product_Segment__c, Product_Sub_segment__c, Purefoil_Segment__c, Quality_requirement__c, Quantity,
    	                                                Quoted_Price_Color__c, QuoteId, Reference_Cap__c, Reference_head__c, Reference_pricing__c,
    	                                                Reference_RFQ_Zephyr__c, Ref_RFQ__c, Regulatory_Affairs__c, Renewal_rate__c,
    	                                                Required_level_of_documentation__c, Resin_Index__c, Rondelle_Insert__c, R_D_Office__c,
    	                                                Sales_price_per_1000_KCur__c, Sales_price_per_1000__c, Sales_value__c, Sampling__c, 
    	                                                selected_corridor__c, ServiceDate, Service_Scoring__c, Shape__c, Shrink_Band__c, Sleeve_Color__c,
    	                                                Sleeve_Finish__c, Sleeve_Length_inches__c, Sleeve_Length_mm__c, Sleeve_material_Mix__c, 
    	                                                Sleeve_type__c, SortOrder, Specific_Product_Image__c, Spray_Tests__c, Stamp__c, Subtotal,
    	                                                SystemModstamp, Tech_key__c, tech_validation_error_update_qli__c, Tech_validation_error__c,
    	                                                Tooling_contribution_k_Cur__c, Tooling_contribution__c, Tooling_Cost_k_Cur__c,
    	                                                Tooling_sales_price_k_Cur__c, Tooling_sales_price_k__c, TotalPrice, Total_contributioin_k_Cur__c,
    	                                                Total_Contribution__c, Total_price_for_Artwork__c, Total_price_for_Preproduction__c,
    	                                                Total_price_for_Samples__c, Total_Sales_value_for_Roll_up__c, Total_Sales_value_k_Cur__c,
    	                                                Total_Sales_value_k__c, Total_Score__c, Training_for_customer__c, Tube_decsription__c,
    	                                                T_Quote_status__c, UnitPrice, US_rate_to_currency__c, Visual_aspect_touch__c, X1_Annual_Quantities__c,
    	                                                X1_MOQ_Option1__c, X1_MOQ_Option2_c__c, X1_MOQ_per_SKU__c, X1_Option_1_3__c, X1_Option_1_4__c,
    	                                                X1_Option_1_5__c, X1_Option_1_6__c, X1_Option_1_7__c, X1_Piece_Price_Currency_per_1000_pieces__c,
    	                                                X1_Weekly_Capacity__c, X2_Annual_Quantities__c, X2_MOQ_Option1_c__c, X2_MOQ_per_SKU__c, 
    	                                                X2_Option_2_2__c, X2_Option_2_3__c, X2_Option_2_4__c, X2_Option_2_5__c, X2_Option_2_6__c,
    	                                                X2_Option_2_7__c, X2_Piece_Price_Currency_per_1000_pieces__c, X2_Weekly_Capacity__c,
    	                                                X3_Annual_Quantities__c, X3_MOQ_per_SKU__c, X3_Piece_Price_Currency_per_1000_pieces__c,
    	                                                X3_Weekly_Capacity__c, X4_Annual_Quantities__c, X4_MOQ_per_SKU__c, 
    	                                                X4_Piece_Price_Currency_per_1000_pieces__c, X4_Weekly_Capacity__c, X5_Annual_Quantities__c,
    	                                                X5_days_lead_time__c, X5_MOQ_per_SKU__c, X5_Piece_Price_Currency_per_1000_pieces__c,
    	                                                X5_Weekly_Capacity__c, X6_Annual_Quantities__c, X6_MOQ_per_SKU__c,
    	                                                X6_Piece_Price_Currency_per_1000_pieces__c, X6_Weekly_Capacity__c, X7_MOQ_per_SKU__c,
    	                                                X7_Piece_Price_Currency_per_1000_pieces__c 
    								               FROM QuoteLineItem
    								              WHERE QuoteId =: this.objectToClone.Id]);
        */
        this.dataInitialisation(qlis.keySet());

    	//We're going to filled the quoteLineItemDeepCloneAgents
    	for(QuoteLineItem qli : qlis.values()){
    		this.quoteLineItemDeepCloneAgents.Add(new AP002_QuoteLineItemDeepCloneAgent(qli, this, this.sameOpportunityFlag, this.sameAccountFlag));
    	}
    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - initializeCloneAgent Stop');
    }
    
    /**
     * [ cleanDealScore Description : will clean the deal score section at the quote level]
     */
    public void cleanDealScore(){
        this.clonedObject.put('Contract_duration__c', null);
        this.clonedObject.put('Exclusivity_Single_vs_Multiple_Supplier__c', null);
        this.clonedObject.put('Alb_a_dependency_to_supplier_s__c', null);
        this.clonedObject.put('Type_of_business__c', null);
        this.clonedObject.put('Multiple_Release_Order_Blanket_Order__c', null);
        this.clonedObject.put('of_month_of_stock_at_Alb_a_expenses__c', null);
        this.clonedObject.put('Indexation_of_raw_material_costs__c', null);
        this.clonedObject.put('Tooling_CAPEX_investments_required__c', null);
        this.clonedObject.put('Penalties_for_the_customer_in_the_contra__c', null);
        this.clonedObject.put('Penalties_in_the_contract_for_Alb_a__c', null);
        this.clonedObject.put('Skonto_for_cash_payment__c', null);
        this.clonedObject.put('Brand_Positionning__c', null);
    }

    /**
     * [ cleanOfferTemplateDetail Description : will clean the offer template section at the quote level]
     */
    public void cleanOfferTemplateDetail(){
        this.clonedObject.put('Contact_Details__c', null);
        this.clonedObject.put('Quantity_Details__c', null);
        this.clonedObject.put('Product_Details__c', null);
        this.clonedObject.put('Supply_Chain_Details__c', null);
        this.clonedObject.put('Indexation_Details__c', null);
        this.clonedObject.put('Service_Details__c', null);
        this.clonedObject.put('Price_details__c', null);
        this.clonedObject.put('Tooling__c'                    , null);
        this.clonedObject.put('Tube_Cap_details__c'           , null);
        this.clonedObject.put('Pa__c'                         , null);
        this.clonedObject.put('Template_offer_Introduction__c', null);
        this.clonedObject.put('Payment_terms_and_details__c'  , null);

    }


    /**
     * [deepClone description : will deep clone the original object]
     */
    public override void deepClone(){
    	TriggerHandler.bypass('PMReviewNetPriceperMoqTrigger');

    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - deepClone Start');
    	
        //The deep cloned quote
    	this.clonedObject = this.objectToClone.clone(false, false, false, false);

        Id newOpportunityID = null;

        //Are we using the same opportunity or not
        if(this.sameOpportunityFlag != null && this.useNewOpportunity != null && this.useSelectedOpportunity != null){
            if(this.sameOpportunityFlag || (! this.useNewOpportunity && ! this.useSelectedOpportunity )){
            }
            else{
                if(this.useNewOpportunity){
                    Date closeDate = Date.newInstance(Integer.valueOf(this.opportunityCloseDate.substring(0,4)), 
                                                        Integer.valueOf(this.opportunityCloseDate.substring(5,7)), 
                                                        Integer.valueOf(this.opportunityCloseDate.substring(8,10)));
                    Opportunity newOpportunity = new Opportunity(
                        Name = this.opportunityName, 
                        StageName = this.opportunityStageName,
                        Quote_Type__c = this.opportunityQuoteType,
                        CloseDate = closeDate
                    );
                    insert(newOpportunity);
                    newOpportunityID = newOpportunity.ID;
                    this.clonedObject.put('OpportunityId', newOpportunity.Id);
                }
                if(this.useSelectedOpportunity){
                    this.clonedObject.put('OpportunityId', this.opportunityId);
                }
            }
        }
        //Bypassing some trigger to ease on SOQL Limit
        TriggerHandler.bypass('PMReviewNetPriceperMOQTriggerHandler');
        TriggerHandler.bypass('PMSelectedDipsensingconfigTriggerHandler');
        TriggerHandler.bypass('PMSelectedTubesConfigTriggerHandler');
        //TriggerHandler.bypass('QuoteLineItemTriggerHandler');


        Id opptyId = (Id) this.clonedObject.get('OpportunityId');

        Opportunity oppty;

        List<Opportunity> oppties = [Select AccountId FROM Opportunity WHERE Id =: opptyId OR Id =: newOpportunityID ];
        if(oppties.size() > 0)
            oppty = oppties.get(0);
        system.Debug(this.objectToClone);
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - this.sameAccountFlag ' + this.sameAccountFlag );

        //Are we using the same account or not
        if(! this.useSelectedOpportunity){
            if(this.sameAccountFlag != null){
                if((! this.sameAccountFlag) && ( this.AccountId != '')){
                    oppty.AccountId = this.AccountId;
                    System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - this.AccountId ' + this.AccountId );
                }
                else{
                    oppty.AccountId = (Id) this.objectToClone.get('AccountId');
                }
                update(oppty);
            }
        }

        //Initialisation of the cloned quote
        this.putDiversFieldsToNull();
        this.putDecisionDateToNull();

        if(this.sameOpportunityFlag != null){
            if(! this.sameOpportunityFlag){
                this.cleanDealScore();
                this.cleanOfferTemplateDetail();
            }
        }

        this.clonedObject.put('ClonedQuote__c', true);

    	insert(this.clonedObject);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - this.clonedObject.get(\'OpportunityId\') : ' + this.clonedObject.get('OpportunityId'));
    	
        // We're going to apply the deep clone function to all the quote line item
        List<SObject> clonedObjects = new List<SObject>();
        set<SObject> clonedObjectsTriee = new set<SObject>();

        //System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - this.getNumberPriceReco() : ' + this.getNumberPriceReco());
    	for(AP002_QuoteLineItemDeepCloneAgent quoteLineItemDeepCloneAgent : quoteLineItemDeepCloneAgents){
    	    quoteLineItemDeepCloneAgent.deepClone();
            quoteLineItemDeepCloneAgent.clonedObject.put('QuoteId' , this.clonedObject.Id);
            clonedObjects.addAll(quoteLineItemDeepCloneAgent.getAllClonedSObject());
    	}

        for(SObject obj : clonedObjects){
            if(!clonedObjectsTriee.contains(obj)){
                Schema.SObjectType type = obj.getSObjectType();
                for(SObject objtype : clonedObjects){
                    if(objtype.getSObjectType() == type){
                        clonedObjectsTriee.add(objtype);
                    }
                }              
                clonedObjectsTriee.add(obj);
            }
        }

        clonedObjects = new List<SObject>();
        clonedObjects.addAll(clonedObjectsTriee);

         //We're going to insert all the cloned object in the data base
        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - clonedObjects.size() ' + clonedObjects.size());
         for(SObject sobj : clonedObjects){
            system.debug(sobj.getSObjectType());
            if(sobj.getSObjectType()== QuoteLineItem.SobjectType )
            {
                system.debug(' quote line item '+sobj.get('Brand__c') + ' '+ sobj.get('Tech_Account__c')+ ' '+ sobj.get('Tech_Customer_Group__c') );
            }
            System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - sobj.Id ' + sobj.Id);
        }
       

        insert(clonedObjects);

        for(AP002_QuoteLineItemDeepCloneAgent quoteLineItemDeepCloneAgent : quoteLineItemDeepCloneAgents){
            if(! this.sameAccountFlag || ! this.sameOpportunityFlag){
                 LC01_PriceRecommendation.getPriceRecommendation(quoteLineItemDeepCloneAgent.clonedObject.Id);
            }
        }

        List<PM_Price_Recommendation__c> priceRecommendation = new List<PM_Price_Recommendation__c>();

        for(AP002_QuoteLineItemDeepCloneAgent quoteLineItemDeepCloneAgent : quoteLineItemDeepCloneAgents){
             priceRecommendation.addAll(quoteLineItemDeepCloneAgent.getAllClonedPMPriceRecommendation());
        }


        insert priceRecommendation;

        // We need to update all the cloned object to have them linked to the correct object
        clonedObjects = new List<SObject>();
        clonedObjectsTriee = new Set<SObject>();
        for(AP002_QuoteLineItemDeepCloneAgent quoteLineItemDeepCloneAgent : quoteLineItemDeepCloneAgents){
            quoteLineItemDeepCloneAgent.updateClonedObject();
            clonedObjects.addAll(quoteLineItemDeepCloneAgent.getAllClonedSObject());
        }

        priceRecommendation = new List<PM_Price_Recommendation__c>();
        for(AP002_QuoteLineItemDeepCloneAgent quoteLineItemDeepCloneAgent : quoteLineItemDeepCloneAgents){
            priceRecommendation.addAll(quoteLineItemDeepCloneAgent.getAllClonedPMPriceRecommendation());
        }
        update(priceRecommendation);


        for(SObject obj : clonedObjects){
            if(!clonedObjectsTriee.contains(obj)){
                Schema.SObjectType type = obj.getSObjectType();
                for(SObject objtype : clonedObjects){
                    if(objtype.getSObjectType() == type && objtype.Id != null){
                        clonedObjectsTriee.add(objtype);
                    }
                }    
                if(obj.Id != null)          
                    clonedObjectsTriee.add(obj);
            }
        }
        clonedObjects = new List<SObject>();
        clonedObjects.addAll(clonedObjectsTriee);
        System.debug(LoggingLevel.DEBUG, LOG_CLASS_NAME + ' - clonedObjects.size() ' + clonedObjects.size());
        User usr = [Select  Profile.Name from User where id = :UserInfo.getUserId() limit 1];
        if (usr.Profile.Name == 'System Administrator'){
            TriggerHandler.bypass('QuoteTriggerHandler');
        }

        update(clonedObjects);

        if (usr.Profile.Name == 'System Administrator'){
            TriggerHandler.clearBypass('QuoteTriggerHandler');
        }



        this.cleanPriceReco();
        priceRecommendation = new List<PM_Price_Recommendation__c>();
        for(AP002_QuoteLineItemDeepCloneAgent quoteLineItemDeepCloneAgent : quoteLineItemDeepCloneAgents){
            quoteLineItemDeepCloneAgent.updateUniqueKeys();
            priceRecommendation.addAll(quoteLineItemDeepCloneAgent.getAllClonedPMPriceRecommendation());
        }
        update(priceRecommendation);

        List<QuoteLineItem> clonedQLIs = new List<QuoteLineItem>();
        for(AP002_QuoteLineItemDeepCloneAgent quoteLineItemDeepCloneAgent : quoteLineItemDeepCloneAgents){
            if(! this.sameAccountFlag || ! this.sameOpportunityFlag){
                 //LC01_PriceRecommendation.getPriceRecommendation(quoteLineItemDeepCloneAgent.clonedObject.Id);
            }
        }

    	
    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - deepClone Stop');	
        TriggerHandler.clearBypass('PMSelectedTubesConfigTriggerHandler');
        TriggerHandler.clearBypass('PMSelectedDipsensingconfigTriggerHandler');
        TriggerHandler.clearBypass('PMReviewNetPriceperMOQTriggerHandler');
    	
    }

    /**
     * [ cleanPriceReco description : will delete the price recommendation generated at some point in the process ]
     */
    public void cleanPriceReco(){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanPriceReco Start.');

        Map<Id, QuoteLineItem> clonedQLIs = new Map<Id, QuoteLineItem>([SELECT Id FROM QuoteLineItem WHERE QuoteId =: this.clonedObject.Id]);
        List<PM_Price_Recommendation__c> pmPriceRecos = [SELECT Id 
                                                           FROM PM_Price_Recommendation__c 
                                                          WHERE Quote_Line_Item__c IN: clonedQLIs.keySet()
                                                            AND Unique_Key__c != NULL];
        delete(pmPriceRecos);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - cleanPriceReco Stop.');
    }

    /**
     * [ dataInitialisation description : will initialise data ]
     */
    public void dataInitialisation(Set<id> QliIds){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - dataInitialisation Start.');

        this.pmMOQPrices 					= database.query(DAL.generateSELECTQuery('PM_MOQ_price__c')+' WHERE moq_max__c != 999 AND Quote_item__c IN: qliIds');                             
        this.pmPriceDetails 				= database.query(DAL.generateSELECTQuery('PM_Price_Detail__c')+' WHERE moq_max__c != 999 AND Quote_item__c IN: qliIds');                                   
        this.pmPriceRecommendations 		= database.query(DAL.generateSELECTQuery('PM_Price_Recommendation__c')+' WHERE Other_moq__c = null AND Quote_Line_Item__c IN: qliIds');                                          
        //this.pmReviewNetPriceperMOQs 		= database.query(DAL.generateSELECTQuery('PM_Review_NetPrice_per_MOQ__c')+' WHERE Quote_Line_Item__c IN: qliIds');        
        this.pmSelectedDispensingConfigs	= database.query(DAL.generateSELECTQuery('PM_Selected_Dipsensing_config__c')+' WHERE Quote_item__c IN: qliIds');        
        this.pmSelectedTubesConfigs 		= database.query(DAL.generateSELECTQuery('PM_Selected_Tubes_Config__c')+' WHERE Quote_item__c IN: qliIds');
        this.pmSelectedServiceTubesConfigs	= database.query(DAL.generateSELECTQuery('PM_Selected_Service_Tubes_Config__c')+' WHERE Quote_item__c IN: qliIds');
      	      	
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - dataInitialisation Stop.');
    }

    /**
     * [ putDecisionDateToNull description : will put the decision date to null ]
     */
    public void putDecisionDateToNull(){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - putDecisionDateToNull Start');

        this.clonedObject.put('date_Quote_Won__c', null);
        this.clonedObject.put('Date_Quote_for_Lost__c', null);
        this.clonedObject.put('Date_Quote_Killed_by_Albea__c', null);
        this.clonedObject.put('Date_Quote_Killed_By_Customer__c', null);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - putDecisionDateToNull Stop');
    }

    /**
     * [ putDiversFieldsToNull description : will put divers field to null]
     */
    public void putDiversFieldsToNull(){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - putDiversFieldsToNull Start');

        this.clonedObject.put('Status', 'Draft');
        this.clonedObject.put('Name', '(Copied) ' + this.clonedObject.get('Name'));
        this.clonedObject.put('Main_compet_1__c', null);        
        this.clonedObject.put('Raison_for_lost_on_won_quote__c', null);
        this.clonedObject.put('TBO_Comment__c', null);
        this.clonedObject.put('Main_compet_2__c', null);
        //Ajout ALE suite à demande OCT 23 octobre
        this.clonedObject.put('First_Delivery_Date__c', null);
        this.clonedObject.put('Quote_due_Date__c', system.today());

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - putDiversFieldsToNull Stop');
    }

}