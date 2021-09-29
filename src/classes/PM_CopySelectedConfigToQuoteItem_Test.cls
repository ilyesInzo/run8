/**
 * <b>Unit Test Class PM_CopySelectedConfigToQuoteItem_Test</b>
 * @author EWA
 * @version 1.1 - Delete SeeAllData, Add AssertEqual Test and @testSetup method
 * @history 1.0 - Version Initiale
 */
@isTest
private class PM_CopySelectedConfigToQuoteItem_Test {
    //Methods of the class PM_CopySelectedConfigToQuoteItem_Test
    /**
     * [testSetup description : data initialisation]
     */
    @testSetup
    static void testSetup(){      
        Id pricebookId = Test.getStandardPricebookId();

        //Create a country for the test
        Country__c country = TestFactory.getFrance();
        insert country;
    
        //Create Test Distribution Channel
        Distribution_Channel__c testDistrib = new Distribution_Channel__c(Name ='Test',Distribution_Channel_Code__c='test',Language_Key__c='test');
        insert testDistrib;
        
        //Create Sales Area
        Sales_Area__c testArea = new Sales_Area__c(Name='Test',Customer_Size__c='GA');
        insert testArea;
        
        //Create an Account for the unit test
        //Account acc = new Account(Name = 'Test Acc 1', Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client',VAT_code__c='1234');
        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        insert acc;
        
        //Create an Opportunity for the unit test
        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
        insert opp;
        
        Product_Sub_segment__c prod2 = new Product_Sub_segment__c(
        	Name = 'Iron Lotion pumps'
      	);
      	insert prod2;
        
        //Create a product2 record for the unit test
        Product2 prod = new Product2(Name = 'Plastic Tube',  Family = 'Tubes', Product_Sub_Segment__c = prod2.Id);
        insert prod;
        
        //Create a PricebookEntry record for the unit test
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        //Create a quote record for the unit test
        Quote q = new Quote(Name = 'Test Quote 1', pricebook2Id = pricebookId, OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today());
        insert q;
        
        // Create a Quote Line Item
        QuoteLineItem qli = new QuoteLineItem(PriceBookEntryId=standardPrice.Id, UnitPrice = 12.0, Product2Id = prod.id, QuoteId = q.Id, Quantity = 20, Ref_RFQ__c = 'Test');
        qli.Market_Of_Application__c = 'BODY CARE'; 
        qli.Customer_Type__c = 'Brand Owner';
        qli.Location__c = 'EU';
        insert qli;
  
        //Insert productSegmentGlobalConfigs
        PM_Global_Config__c productSegmentGlobalConfigs = new  PM_Global_Config__c();
        productSegmentGlobalConfigs.Table_name__c = 'Product Segment';
        productSegmentGlobalConfigs.Product_Segment__c = 'Plastic Tube';
        productSegmentGlobalConfigs.Location__c = 'EU';
        productSegmentGlobalConfigs.Name_for_discount_corridors__c ='TEST_CORRIDOR_1';        
        insert productSegmentGlobalConfigs;
        
        //Insert marketAppGlobalConfigs
        PM_Global_Config__c marketAppGlobalConfigs = new  PM_Global_Config__c();
        marketAppGlobalConfigs.Table_name__c = 'Market of Application';
        marketAppGlobalConfigs.Location__c = 'EU';
        marketAppGlobalConfigs.Market_of_Application__c = 'BODY CARE';
        marketAppGlobalConfigs.Name_for_discount_corridors__c ='TEST_CORRIDOR_MARKET';        
        insert marketAppGlobalConfigs;
        
        //Insert macroMarketAppGlobalConfigs 
        PM_Global_Config__c macroMarketAppGlobalConfigs = new  PM_Global_Config__c();
        macroMarketAppGlobalConfigs.Table_name__c = 'Customer Type';
        macroMarketAppGlobalConfigs.Location__c = 'EU';
        macroMarketAppGlobalConfigs.Customer_Type__c = 'Brand owner';
        macroMarketAppGlobalConfigs.Name_for_discount_corridors__c = '2';        
        insert macroMarketAppGlobalConfigs;
        
        // create selected PM_Selected_Tubes_Config__c        
        PM_Selected_Tubes_Config__c stc= new PM_Selected_Tubes_Config__c(Quote_item__c=qli.Id,Location__c = 'EU');
        insert stc;
    }

    /**
     * [getQli description : return the QuoteLineItem created in the data initialisation phase]
     * @return [QuoteLineItem : the created QuoteLineItem]
     */
    private static QuoteLineItem getQli(){
        return [SELECT PriceBookEntryId, UnitPrice, Product2Id, QuoteId, Quantity, Market_Of_Application__c, 
                        Customer_Type__c, Location__c
                FROM QuoteLineItem
                LIMIT 1];
    }

    /**
     * [getPMStc description : return the Selected Tube Config record in the data initialisation phase]
     * @return [PM_Selected_Tubes_Config__c : the created Selected Tube Config]
     */ 
    private static PM_Selected_Tubes_Config__c getPMStc(){
        return [SELECT Quote_item__c, Location__c, Diameter_mm__c, Sleeve_length_mm__c, Sleeve_type__c,
                        Sleeve_Material_Mix__c, Shape__c, Sleeve_Aspect__c, Sleeve_Color__c, NB_Flexo_Colors__c,
                        NB_Offset_Colors__c, NB_SS_Colors__c, Printing_Effects__c, Deco_Hot_Stamping__c,
                        Cap_Eurocode__c, Cap_Name__c, Cap_Color__c, Hot_Stamp_Top__c, HS_Contouring__c,
                        Silk_screen__c, Metallization__c, Shrink_band__c, Manual_Capping__c, Dispensing_System_Family__c,
                        Head_Name__c, Head_Color__c, Peel_Seal__c, insert__c, PE_bag__c,Polysheet__c, Nouveau_Platts__c, rondelle__c,
                        Delivery__c, Destination__c, Actuator_Type__c, Diameter_inches__c, Sleeve_Length_inches__c,
                        Sleeve_Material__c, Sleeve_Finish_name__c, Head_Aspect__c
                FROM PM_Selected_Tubes_Config__c
                LIMIT 1];
    }


    /**
     * [populateQuoteItemFromTubesConfig_Test description]
     */
    @isTest
    static void populateQuoteItemFromTubesConfig_Test(){    
        QuoteLineItem qli = getQli();
        PM_Selected_Tubes_Config__c stc = getPMStc();

    	Test.startTest();
        
        QuoteLineItem result = PM_CopySelectedConfigToQuoteItem.populateQuoteItemFromTubesConfig(stc, qli);
        System.assertNotEquals(null, result, 'PM_CopySelectedConfigToQuoteItem.populateQuoteItemFromTubesConfig did not send back data');

    	Test.stopTest();	
    }
    

}