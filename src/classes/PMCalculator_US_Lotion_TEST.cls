/**
 * <b>Class Unit Test PMCalculator_US_Lotion_TEST</b>
 * @author Eric Wartelle
 * @version 1.1 - Assert Equal Test, Refactoring and Pretty printing
 * @history 1.1 - Assert Equal Test, Refactoring and Pretty printing
 *          1.0 - Initiale Version
 */
@isTest
public class PMCalculator_US_Lotion_TEST {
    /**
     * [testMethod1 description]
     */
    static testmethod void testMethod1(){     
    	//Create Test Data
        Country__c country = TestFactory.getUSA();
        insert country;
    
        //Create Test Distribution Channel
        Distribution_Channel__c testDistrib = new Distribution_Channel__c(Name = 'Test', Distribution_Channel_Code__c = 'test', Language_Key__c = 'test');
        insert testDistrib;
        
        //Create Sales Area
        Sales_Area__c testArea = new Sales_Area__c(Name = 'Test', Customer_Size__c = 'GA');
        insert testArea;
        
        //Create Test Accounts
        //Account acc = new Account(Name = 'Test Acc 1' + datetime.now(), Country__c = country.Id, Distribution_Channel__c = testDistrib.id, 
        //                            Sales_Area__c = testArea.id, Account_status__c = 'Active', Type = 'Client');
        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        insert acc;
        
        //Get Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();
    
        //Create an Opportunity for Test purpose
        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
        insert opp;
    
        //Create a Quote for Test purpose
        Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), 
                            date_Quote_Won__c = Date.today(), Status = 'Draft', Skonto_for_cash_payment__c = '3');
        insert q; 
        
        Product_Sub_segment__c prod2 = new Product_Sub_segment__c(
        	Name = 'Iron Lotion pumps'
      	);
      	insert prod2;
        
        //Create a Product2 record for Test purpose
        Product2 prod = new Product2(Name = 'Lotion pumps', Family = 'Bottle', IsActive=true, Product_Sub_Segment__c = prod2.Id);
        insert prod;
     
        //Create a PricebookEntry for Test purpose
     	PricebookEntry standardPrice = new PricebookEntry( Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;

    	//Insert QLI
        QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0, Quantity = 100, PricebookEntryId = standardPrice.id, Product2Id = prod.id, QuoteId = q.Id, Ref_RFQ__c = 'Test');        
        qli.Market_Of_Application__c = 'BODY CARE';
        qli.Customer_Type__c = 'Brand Owner';
        qli.Location__c = 'US';
        qli.Customer_end_of_year_rebate__c = 'Yes (1%)';
        insert qli;

        //Create Price Details
       /* List<PM_price_detail__c> priceDetails = new list<PM_price_detail__c>();       
        for(integer i=1; i<=4; i++){            
            PM_price_detail__c newPriceDetails = new PM_price_detail__c();
            newPriceDetails.Quote_item__c = qli.id;
            newPriceDetails.MOQ_Min__c = 10;
            newPriceDetails.MOQ_Max__c = 20;
            newPriceDetails.List_Price__c = i+10.50;
            newPriceDetails.Name = 'test'+i;            
            priceDetails.add(newPriceDetails);
        }
        insert priceDetails;*/

        Test.startTest();
        
        LC01_Review_EU_PlasticController.detailReviewMapClass testMaps = new LC01_Review_EU_PlasticController.detailReviewMapClass();            
        testMaps = LC01_Review_EU_PlasticController.getPriceDetails(qli.id, 15);        
        testMaps.ReviewPriceMap = LC01_Review_EU_PlasticController.setAllDiscounts(200, 250, testMaps.PriceDetailMap,  testMaps.ReviewPriceMap);        
        testMaps.ReviewPriceMap = LC01_Review_EU_PlasticController.updatedReviewPriceMap(testMaps.ReviewPriceMap);

        System.assertNotEquals(null, testMaps, 'LC01_Review_EU_PlasticController.getPriceDetails did not send back any data');
        
        //Insert PM_MOQ_price__c
        PM_MOQ_price__c testMOQPrice = New  PM_MOQ_price__c();        
        testMOQPrice.Quote_item__c = qli.id;
        testMOQPrice.MOQ_Max__c = 50;
        testMOQPrice.MOQ_Min__c = 25;
        testMOQPrice.List_Price__c = 200.50;        
        insert testMOQPrice;
         
        //Insert productSegmentGlobalConfigs
        PM_Global_Config__c productSegmentGlobalConfigs = new  PM_Global_Config__c();
        productSegmentGlobalConfigs.Table_name__c = 'Product Segment';
        productSegmentGlobalConfigs.Product_Segment__c = 'Lotion pumps';
        productSegmentGlobalConfigs.Location__c = 'US';
        productSegmentGlobalConfigs.Name_for_discount_corridors__c ='TEST_CORRIDOR_1';        
        insert productSegmentGlobalConfigs;
        
        //Insert marketAppGlobalConfigs
        PM_Global_Config__c marketAppGlobalConfigs = new  PM_Global_Config__c();
        marketAppGlobalConfigs.Table_name__c = 'Market of Application';
        marketAppGlobalConfigs.Location__c = 'US';
        marketAppGlobalConfigs.Market_of_Application__c = 'BODY CARE';
        marketAppGlobalConfigs.Name_for_discount_corridors__c ='TEST_CORRIDOR_MARKET';        
        insert marketAppGlobalConfigs;
        
        //Insert macroMarketAppGlobalConfigs 
        PM_Global_Config__c macroMarketAppGlobalConfigs = new  PM_Global_Config__c();
        macroMarketAppGlobalConfigs.Table_name__c = 'Customer Type';
        macroMarketAppGlobalConfigs.Location__c = 'US';
        macroMarketAppGlobalConfigs.Customer_Type__c = 'Brand owner';
        macroMarketAppGlobalConfigs.Name_for_discount_corridors__c = '4';        
        insert macroMarketAppGlobalConfigs;

        //  insert testSelectedConfig;
       /* PM_Selected_Dipsensing_config__c testSelectedConfig = new PM_Selected_Dipsensing_config__c();
        testSelectedConfig.Quote_item__c = qli.id;
        testSelectedConfig.Location__c = 'US';
        testSelectedConfig.Product_Type__c = 'TEST';
        testSelectedConfig.Cap__c = 'TEST';
        testSelectedConfig.Pack_Name__c ='Test';
        testSelectedConfig.Bottle_Volume__c ='Test';
        testSelectedConfig.Actuator_Finishing__c = 'TEST';
        testSelectedConfig.Collar__c = 'Test';
        testSelectedConfig.Collar_Finishing__c = 'TEST';
        testSelectedConfig.Cap_Finishing__c = 'Test';
        testSelectedConfig.Coloring__c ='Test';
        testSelectedConfig.Actuator__c = 'Test';
        testSelectedConfig.Engine_Name__c 
        insert testSelectedConfig;*/



        PM_Dispensing_Pricing__c testPricing = new PM_Dispensing_Pricing__c();
        testPricing.Version__c = 3;
        testPricing.Location__c = 'US';
        testPricing.Product_Segment__c = 'Lotion pumps';
        testPricing.X10__c = 5;
        testPricing.X15__c = 5;
        testPricing.X20__c = 5;
        testPricing.X25__c = 5;
        testPricing.X250__c = 5;
        testPricing.Ref__c = 'Complete Pack_D.N.Airless ø41_SP34D_ELITE_CRIMP ON_0_yes_NULL_TEST_TEST';   
        testPricing.Valid_From__c = Date.today();
        testPricing.Valid_To__c = Date.today().addDays(30);     
        insert testPricing;

        PM_Dispensing_Pricing__c testPricing2 = new PM_Dispensing_Pricing__c();
        testPricing2.Version__c = 3;
        testPricing2.Location__c = 'US';
        testPricing2.Product_Segment__c = 'Lotion pumps';
        testPricing2.X10__c = 5;
        testPricing2.X15__c = 5;
        testPricing2.X20__c = 5;
        testPricing2.X25__c = 5;
        testPricing2.X250__c = 5;
        testPricing2.Ref__c = 'yes';   
        testPricing2.Valid_From__c = Date.today();
        testPricing2.Valid_To__c = Date.today().addDays(30);     
        insert testPricing2;

        PM_Dispensing_Pricing__c testPricing3 = new PM_Dispensing_Pricing__c();
        testPricing3.Version__c = 3;
        testPricing3.Location__c = 'US';
        testPricing3.Product_Segment__c = 'Lotion pumps';
        testPricing3.X10__c = 5;
        testPricing3.X15__c = 5;
        testPricing3.X20__c = 5;
        testPricing3.X25__c = 5;
        testPricing3.X250__c = 5;
        testPricing3.Ref__c = 'SP34D_Elite_TEST';   
        testPricing3.Valid_From__c = Date.today();
        testPricing3.Valid_To__c = Date.today().addDays(30);     
        insert testPricing3;

        PM_Dispensing_Pricing__c testPricing4 = new PM_Dispensing_Pricing__c();
        testPricing4.Version__c = 3;
        testPricing4.Location__c = 'US';
        testPricing4.Product_Segment__c = 'Lotion pumps';
        testPricing4.X10__c = 5;
        testPricing4.X15__c = 5;
        testPricing4.X20__c = 5;
        testPricing4.X25__c = 5;
        testPricing4.X250__c = 5;
        testPricing4.Ref__c = 'D.N.Airless ø41_Test_Le Tréport';   
        testPricing4.Valid_From__c = Date.today();
        testPricing4.Valid_To__c = Date.today().addDays(30);     
        insert testPricing4;

        PM_Dispensing_Pricing__c testPricing5 = new PM_Dispensing_Pricing__c();
        testPricing5.Version__c = 3;
        testPricing5.Location__c = 'US';
        testPricing5.Product_Segment__c = 'Lotion pumps';
        testPricing5.X10__c = 5;
        testPricing5.X15__c = 5;
        testPricing5.X20__c = 5;
        testPricing5.X25__c = 5;
        testPricing5.X250__c = 5;
        testPricing5.Ref__c = 'SP34D_Elite_TEST_Actuator color_0';   
        testPricing5.Valid_From__c = Date.today();
        testPricing5.Valid_To__c = Date.today().addDays(30);     
        insert testPricing5;

        PM_Dispensing_Pricing__c testPricing6 = new PM_Dispensing_Pricing__c();
        testPricing6.Version__c = 3;
        testPricing6.Location__c = 'US';
        testPricing6.Product_Segment__c = 'Lotion pumps';
        testPricing6.X10__c = 5;
        testPricing6.X15__c = 5;
        testPricing6.X20__c = 5;
        testPricing6.X25__c = 5;
        testPricing6.X250__c = 5;
        testPricing6.Ref__c = 'SP34D_Elite_TEST_Collar color_0';   
        testPricing6.Valid_From__c = Date.today();
        testPricing6.Valid_To__c = Date.today().addDays(30);     
        insert testPricing6;

        PM_Dispensing_Pricing__c testPricing7 = new PM_Dispensing_Pricing__c();
        testPricing7.Version__c = 3;
        testPricing7.Location__c = 'US';
        testPricing7.Product_Segment__c = 'Lotion pumps';
        testPricing7.X10__c = 5;
        testPricing7.X15__c = 5;
        testPricing7.X20__c = 5;
        testPricing7.X25__c = 5;
        testPricing7.X250__c = 5;
        testPricing7.Ref__c = 'SP34D_Elite_TEST_Cap color';   
        testPricing7.Valid_From__c = Date.today();
        testPricing7.Valid_To__c = Date.today().addDays(30);     
        insert testPricing7;

        PM_Dispensing_Pricing__c testPricing8 = new PM_Dispensing_Pricing__c();
        testPricing8.Version__c = 3;
        testPricing8.Location__c = 'US';
        testPricing8.Product_Segment__c = 'Lotion pumps';
        testPricing8.X10__c = 5;
        testPricing8.X15__c = 5;
        testPricing8.X20__c = 5;
        testPricing8.X25__c = 5;
        testPricing8.X250__c = 5;
        testPricing8.Ref__c = 'SP34D_Insert color';   
        testPricing8.Valid_From__c = Date.today();
        testPricing8.Valid_To__c = Date.today().addDays(30);     
        insert testPricing8;

        PM_Dispensing_Pricing__c testPricing9 = new PM_Dispensing_Pricing__c();
        testPricing9.Version__c = 3;
        testPricing9.Location__c = 'US';
        testPricing9.Product_Segment__c = 'Lotion pumps';
        testPricing9.X10__c = 5;
        testPricing9.X15__c = 5;
        testPricing9.X20__c = 5;
        testPricing9.X25__c = 5;
        testPricing9.X250__c = 5;
        testPricing9.Ref__c = 'D.N.Airless ø41_Test';   
        testPricing9.Valid_From__c = Date.today();
        testPricing9.Valid_To__c = Date.today().addDays(30);     
        insert testPricing9;

        PM_Dispensing_Pricing__c testPricing10 = new PM_Dispensing_Pricing__c();
        testPricing10.Version__c = 3;
        testPricing10.Location__c = 'US';
        testPricing10.Product_Segment__c = 'Lotion pumps';
        testPricing10.X10__c = 5;
        testPricing10.X15__c = 5;
        testPricing10.X20__c = 5;
        testPricing10.X25__c = 5;
        testPricing10.X250__c = 5;
        testPricing10.Ref__c = 'PBT body_SP34D';   
        testPricing10.Valid_From__c = Date.today();
        testPricing10.Valid_To__c = Date.today().addDays(30);     
        insert testPricing10;

        PM_Dispensing_Pricing__c testPricing11 = new PM_Dispensing_Pricing__c();
        testPricing11.Version__c = 3;
        testPricing11.Location__c = 'US';
        testPricing11.Product_Segment__c = 'Lotion pumps';
        testPricing11.X10__c = 5;
        testPricing11.X15__c = 5;
        testPricing11.X20__c = 5;
        testPricing11.X25__c = 5;
        testPricing11.X250__c = 5;
        testPricing11.Ref__c = 'Complete Pack_D.N.Airless ø41';   
        testPricing11.Valid_From__c = Date.today();
        testPricing11.Valid_To__c = Date.today().addDays(30);     
        insert testPricing11;
        
        PM_Dispensing_Pricing__c testPricing12 = new PM_Dispensing_Pricing__c();
        testPricing12.Version__c = 3;
        testPricing12.Location__c = 'US';
        testPricing12.Product_Segment__c = 'Lotion pumps';
        testPricing12.X10__c = 5;
        testPricing12.X15__c = 5;
        testPricing12.X20__c = 5;
        testPricing12.X25__c = 5;
        testPricing12.X250__c = 5;
        testPricing12.Ref__c = 'Diptube length_SP34D_Standard (<140mm)';   
        testPricing12.Valid_From__c = Date.today();
        testPricing12.Valid_To__c = Date.today().addDays(30);     
        insert testPricing12;

        //  insert testSelectedConfig;
        PM_Selected_Dipsensing_config__c testSelectedConfig = new PM_Selected_Dipsensing_config__c();
        testSelectedConfig.Quote_item__c = qli.id;
        testSelectedConfig.Location__c = 'US';
        testSelectedConfig.Product_segment__c = 'Lotion pumps';
        testSelectedConfig.Product_Type__c = 'Complete Pack';
        testSelectedConfig.Cap__c = 'TEST';
        testSelectedConfig.Pack_Name__c ='D.N.Airless ø41';
        testSelectedConfig.Bottle_Volume__c ='Test';
        testSelectedConfig.Actuator_Finishing__c = 'TEST';
        testSelectedConfig.Collar__c = 'Test';
        testSelectedConfig.Collar_Finishing__c = 'TEST';
        testSelectedConfig.Cap_Finishing__c = 'Test';
        testSelectedConfig.Coloring__c ='Test';
        testSelectedConfig.Actuator__c = 'Test';
        testSelectedConfig.Engine_Name__c = 'SP34D';
        testSelectedConfig.Pump_Segmentation__c = 'Elite';
        testSelectedConfig.Attachment__c = 'Crimp On';
        testSelectedConfig.Actuator__c = 'yes';
        testSelectedConfig.Insert_Finishing__c = 'Non Standard';
        testSelectedConfig.PBT_Body__c = 'Yes - extra cost';
        testSelectedConfig.Diptube_Length__c = 'Standard (<140mm)';
        insert testSelectedConfig;
         


         
        AP00_LotionLeadTime.calcLotionLeadTime(testSelectedConfig);

        PMCalculator_US_Lotion pmCalcUSLotion = new PMCalculator_US_Lotion(testSelectedConfig);
        pmCalcUSLotion.calculate();
         System.assertNotEquals(0, [select Id from PM_Price_Detail__c].size());
        Test.stopTest();     
     }
    
}