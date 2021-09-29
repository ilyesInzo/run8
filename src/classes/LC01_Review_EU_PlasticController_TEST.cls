/**
 * <b>Unit Test Class LC01_Review_EU_PlasticController_TEST</b>
 * @author EWA
 * @version 1.1 - @testSetup and Assert Call
 * @history 1.1 - @testSetup and Assert Call
 *          1.0 - Original
 */
@isTest
public class LC01_Review_EU_PlasticController_TEST {
    //Attributs of the class LC01_Review_EU_PlasticController_TEST
    public static String LOG_CLASS_NAME = 'LC01_Review_EU_PlasticController_TEST';

	//Methods of the class LC01_Review_EU_PlasticController_TEST
    /**
     * [testSetup description : data intialisation ]
     */
    @testSetup
    static void testSetup(){
        String pid = [Select id from Profile where Name='System Administrator'].Id; 
       
         //Create Test Data
        Country__c country = new Country__c(Name = 'Germany', Country_Code__c = 'DE');
        insert country;
    
        //Create Test Distribution Channel
        Distribution_Channel__c testDistrib = new Distribution_Channel__c(Name ='Test',Distribution_Channel_Code__c='test',Language_Key__c='test');
        insert testDistrib;
        
        //Create Sales Area
        Sales_Area__c testArea = new Sales_Area__c(Name='Test',Customer_Size__c='GA');
        insert testArea;
        
        //Create Test Accounts
        //Account acc = new Account(Name = 'Test Acc 1'+datetime.now(), Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        insert acc;
        
        //Get Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();
    
        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
        insert opp;
    
        Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Draft',Skonto_for_cash_payment__c='3');
        insert q; 
        
        Product2 prod = new Product2(Name = 'Lotion pumps', 
                                     Family = 'Bottle', IsActive=true);
        insert prod;
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        //Insert QLI
        QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0,Quantity = 100,PricebookEntryId= standardPrice.id,
                                                  Product2Id = prod.id, QuoteId = q.Id
                                                  );
        
        qli.Market_Of_Application__c = 'BODY CARE';
        qli.Customer_Type__c = 'Brand Owner';
        qli.Location__c = 'EU';
        qli.Customer_end_of_year_rebate__c = 'Yes (1%)';
        insert qli;
 
        //Create Price Details
        List<PM_price_detail__c> priceDetails = new list<PM_price_detail__c>();
        
        for(integer i=1; i<=5; i++){
            
            PM_price_detail__c newPriceDetails = new PM_price_detail__c();
            newPriceDetails.Quote_item__c = qli.id;
            newPriceDetails.MOQ_Min__c = 10;
            newPriceDetails.MOQ_Max__c = 20;
            newPriceDetails.List_Price__c = i+10.50;
            newPriceDetails.Name = i+'test';
            
            priceDetails.add(newPriceDetails);
        }
        insert priceDetails;
    }

    /**
     * [testMethod1 definition]
     */
    @isTest
    static void testMethod1(){
        //Getting back the information from the database
        QuoteLineItem qli = [SELECT UnitPrice, Quantity, PricebookEntryId, Product2Id, QuoteId,
                                    Market_Of_Application__c, Customer_Type__c, Location__c,
                                    Customer_end_of_year_rebate__c FROM QuoteLineitem LIMIT 1];
        List<PM_price_detail__c> priceDetails = [SELECT Quote_item__c, MOQ_Min__c, MOQ_Max__c,
                                                 List_Price__c, Name FROM PM_price_detail__c LIMIT 5 ];
        TriggerHandler.bypass('QuoteTriggerHandler');
        TriggerHandler.bypass('PMReviewNetPriceperMoqTriggerHandler');
        LC01_Review_EU_PlasticController.detailReviewMapClass testMaps = new LC01_Review_EU_PlasticController.detailReviewMapClass();
        testMaps = LC01_Review_EU_PlasticController.getPriceDetails(qli.id, 15);
        testMaps.ReviewPriceMap = LC01_Review_EU_PlasticController.setAllDiscounts(200, 250, testMaps.PriceDetailMap,  testMaps.ReviewPriceMap);
        testMaps.ReviewPriceMap = LC01_Review_EU_PlasticController.updatedReviewPriceMap(testMaps.ReviewPriceMap);

        //System.assert 
        System.assertNotEquals(null, testMaps, 'LC01_Review_EU_PlasticController.getPriceDetails did not send any data');
        System.assertNotEquals(null, testMaps.PriceDetailMap, 'LC01_Review_EU_PlasticController.getPriceDetails did not send any data');
        System.assertNotEquals(null, testMaps.ReviewPriceMap, 'LC01_Review_EU_PlasticController.getPriceDetails did not send any data');
 
        //Insert productSegmentGlobalConfigs
        PM_Global_Config__c productSegmentGlobalConfigs = new  PM_Global_Config__c();
        productSegmentGlobalConfigs.Table_name__c = 'Product Segment';
        productSegmentGlobalConfigs.Product_Segment__c = 'Lotion pumps';
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
        macroMarketAppGlobalConfigs.Name_for_discount_corridors__c = '4';    
        insert macroMarketAppGlobalConfigs;
        
        //Insert Test PM_Selected_Dipsensing_config__c
        PM_Selected_Dipsensing_config__c testSelectedConfig = new PM_Selected_Dipsensing_config__c();
        testSelectedConfig.Quote_item__c = qli.id;
        testSelectedConfig.Location__c = 'EU';
        testSelectedConfig.Product_Type__c = 'TEST';
        testSelectedConfig.Cap__c = 'TEST';
        testSelectedConfig.Pack_Name__c ='Test';
        testSelectedConfig.Bottle_Volume__c ='Test';
        testSelectedConfig.Actuator_Finishing__c = 'TEST';
        testSelectedConfig.Collar_Finishing__c = 'TEST';
        testSelectedConfig.Cap_Finishing__c = 'Test';
        testSelectedConfig.Coloring__c ='Test';
        insert testSelectedConfig;
        
        //Insert Price Recommendation
        PM_Price_Recommendation__c testRecommendation = new PM_Price_Recommendation__c();
        testRecommendation.PM_Selected_Dipsensing_Config__c = testSelectedConfig.Id;
        testRecommendation.Quote_Line_Item__c = qli.id;
        testRecommendation.MOQ__c = 25;        
        testRecommendation.Min_Threshhold_Price__c = 300;
        testRecommendation.Lin1_Price__c = 250;
        testRecommendation.Lin2_Price__c = 200;
        testRecommendation.Lin3_Price__c = 190;
        testRecommendation.Max_Threshhold_Price__c = 180;        
        insert testRecommendation;
        
        
        //Final Price Offer Controller Test
        LC01_RECO_FinalPriceOfferController.getFinalReviewPrices(qli.id);        
        List<PM_Review_NetPrice_per_MOQ__c> pmRNPs = new List<PM_Review_NetPrice_per_MOQ__c>();
        for(PM_Price_Detail__c pmPD : priceDetails) {
            PM_Review_NetPrice_per_MOQ__c testFinalReview = new PM_Review_NetPrice_per_MOQ__c();
            testFinalReview.Selected__c = true;
            testFinalReview.Quote_Line_Item__c = qli.Id;
            testFinalReview.PM_Price_Detail__c = pmPD.Id;
            pmRNPs.add(testFinalReview);
        }
        insert pmRNPs;
        
        List<PM_Review_NetPrice_per_MOQ__c> reviewPrices = [select id,Selected__c from PM_Review_NetPrice_per_MOQ__c where Quote_Line_Item__c=:qli.id];
        
        PM_Review_NetPrice_per_MOQ__c selected = LC01_RECO_FinalPriceOfferController.selected(reviewPrices);
        PM_MOQ_price__c MOQPrice1 = [select id,List_Price__c,Quote_item__c,MOQ_Max__c,MOQ_Min__c from PM_MOQ_price__c where Quote_item__c=:qli.id and MOQ_Min__c<=30 and MOQ_Max__c>:30]; 
                
        MOQPrice1.List_Price__c = 200;
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' --- MOQPRICE1 --- '+MOQPrice1);
        update MOQPrice1;
        
        //Update Final Review
        pmRNPs[0].Quoted_Price__c = 244.450;
        pmRNPs[0].MOQ_Units__c = 30;
        pmRNPs[0].Selected__c = true;        
        update pmRNPs[0];
        
        pmRNPs[0].Quoted_Price__c = 195.25;
        pmRNPs[0].Selected__c = true;        
        update pmRNPs[0];
        
    }
}