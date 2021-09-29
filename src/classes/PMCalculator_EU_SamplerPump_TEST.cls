/**
 * <b>Unit Classe Test PMCalculator_EU_SamplerPump_TEST </b>
 * @author EWA
 * @version 1.1 - AssertEqual test and Pretty printing
 * @history 1.1 - AssertEqual test and Pretty printing
 *          1.0 - Version Initiale
 */ 
@isTest
public class PMCalculator_EU_SamplerPump_TEST {
    //Methods for the class PMCalculator_EU_SamplerPump_TEST
    /**
     * [testMethod1 description]
     */
    @isTest	
    static void testMethod1(){        
        String pid = [Select id from Profile where Name='System Administrator'].Id; 
       
    	 //Create Test Data
        Country__c country = TestFactory.getGermany();
        insert country;
    
        //Create Test Distribution Channel
        Distribution_Channel__c testDistrib = new Distribution_Channel__c(Name = 'Test', Distribution_Channel_Code__c = 'test', Language_Key__c = 'test');
        insert testDistrib;
        
        //Create Sales Area
        Sales_Area__c testArea = new Sales_Area__c(Name = 'Test', Customer_Size__c = 'GA');
        insert testArea;
        
        //Create Test Accounts
        //Account acc = new Account(Name = 'Test Acc 1' + datetime.now(), Country__c = country.Id, Distribution_Channel__c = testDistrib.id,
        //                            Sales_Area__c = testArea.id, Account_status__c = 'Active', Type = 'Client', VAT_code__c = '1234');
        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        insert acc;
        
        //Get Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();
    
        //Create an Opportunity for test purpose
        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
        insert opp;

        //Create a Quote for test purpose
        Quote q = new Quote(pricebook2Id = pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), 
                                date_Quote_Won__c = Date.today(),  Status = 'Draft', Skonto_for_cash_payment__c = '3');
        insert q; 
        
        Product_Sub_segment__c prod2 = new Product_Sub_segment__c(
        	Name = 'Iron Lotion pumps'
      	);
      	insert prod2;
        
        //Create a Product2 record for test purpose
        Product2 prod = new Product2(Name = 'Sampler pumps', Family = 'Bottle',	IsActive=true, Product_Sub_Segment__c = prod2.Id);
        insert prod;
     
     	PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;

    	//Insert QLI
        QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0,Quantity = 100,PricebookEntryId= standardPrice.id,
                                                  Product2Id = prod.id, QuoteId = q.Id, Ref_RFQ__c = 'Test');        
        qli.Market_Of_Application__c = 'BODY CARE';
        qli.Customer_Type__c = 'Brand Owner';
        qli.Location__c = 'EU';
        qli.Customer_end_of_year_rebate__c = 'Yes (1%)';
        qli.DS_Skonto_for_cash_payment__c = '3%';
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
        
        //Assert Equals test
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
        productSegmentGlobalConfigs.Product_Segment__c = 'Sampler pumps';
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

        //PM_Dispensing_Pricing__c
        PM_Dispensing_Pricing__c testPricing = new PM_Dispensing_Pricing__c();
        testPricing.Version__c = 3;
        testPricing.Location__c = 'EU';
        testPricing.Product_Segment__c = 'Sampler pumps';
        testPricing.X10__c = 5;
        testPricing.X15__c = 5;
        testPricing.X20__c = 5;
        testPricing.X25__c = 5;
        testPricing.Ref__c = 'TESTTestTest';        
        insert testPricing;


        //PM_Dispensing_Pricing__c
        PM_Dispensing_Pricing__c testPricing2 = new PM_Dispensing_Pricing__c();
        testPricing2.Version__c = 3;
        testPricing2.Location__c = 'EU';
        testPricing2.Product_Segment__c = 'Sampler pumps';
        testPricing2.X10__c = 5;
        testPricing2.X15__c = 5;
        testPricing2.X20__c = 5;
        testPricing2.X25__c = 5;
        testPricing2.Ref__c = 'Full Pump (separate actuator)_TEST_Test_Test';        
        insert testPricing2;

        //PM_Dispensing_Pricing__c
        PM_Dispensing_Pricing__c testPricing3 = new PM_Dispensing_Pricing__c();
        testPricing3.Version__c = 3;
        testPricing3.Location__c = 'EU';
        testPricing3.Product_Segment__c = 'Sampler pumps';
        testPricing3.X10__c = 5;
        testPricing3.X15__c = 5;
        testPricing3.X20__c = 5;
        testPricing3.X25__c = 5;
        testPricing3.Ref__c = 'TEST_null__null';        
        insert testPricing3;

        //PM_Dispensing_Pricing__c
        PM_Dispensing_Pricing__c testPricing4 = new PM_Dispensing_Pricing__c();
        testPricing4.Version__c = 3;
        testPricing4.Location__c = 'EU';
        testPricing4.Product_Segment__c = 'Sampler pumps';
        testPricing4.X10__c = 5;
        testPricing4.X15__c = 5;
        testPricing4.X20__c = 5;
        testPricing4.X25__c = 5;
        testPricing4.Ref__c = 'TEST_Test_TEST';        
        insert testPricing4;

        //PM_Dispensing_Pricing__c
        PM_Dispensing_Pricing__c testPricing5 = new PM_Dispensing_Pricing__c();
        testPricing5.Version__c = 3;
        testPricing5.Location__c = 'EU';
        testPricing5.Product_Segment__c = 'Sampler pumps';
        testPricing5.X10__c = 5;
        testPricing5.X15__c = 5;
        testPricing5.X20__c = 5;
        testPricing5.X25__c = 5;
        testPricing5.Ref__c = 'TESTPumpPump Metallization';        
        insert testPricing5;

        //PM_Dispensing_Pricing__c
        PM_Dispensing_Pricing__c testPricing6 = new PM_Dispensing_Pricing__c();
        testPricing6.Version__c = 3;
        testPricing6.Location__c = 'EU';
        testPricing6.Product_Segment__c = 'Sampler pumps';
        testPricing6.X10__c = 5;
        testPricing6.X15__c = 5;
        testPricing6.X20__c = 5;
        testPricing6.X25__c = 5;
        testPricing6.Ref__c = 'TESTinsertStd';        
        insert testPricing6;

        //PM_Dispensing_Pricing__c
        PM_Dispensing_Pricing__c testPricing7 = new PM_Dispensing_Pricing__c();
        testPricing7.Version__c = 3;
        testPricing7.Location__c = 'EU';
        testPricing7.Product_Segment__c = 'Sampler pumps';
        testPricing7.X10__c = 5;
        testPricing7.X15__c = 5;
        testPricing7.X20__c = 5;
        testPricing7.X25__c = 5;
        testPricing7.Ref__c = 'TESTCollarCollar Metallization';        
        insert testPricing7;

        //PM_Dispensing_Pricing__c
        PM_Dispensing_Pricing__c testPricing8 = new PM_Dispensing_Pricing__c();
        testPricing8.Version__c = 3;
        testPricing8.Location__c = 'EU';
        testPricing8.Product_Segment__c = 'Sampler pumps';
        testPricing8.X10__c = 5;
        testPricing8.X15__c = 5;
        testPricing8.X20__c = 5;
        testPricing8.X25__c = 5;
        testPricing8.Ref__c = 'TESTCapMetallization';        
        insert testPricing8;

        //  insert testSelectedConfig;
        PM_Selected_Dipsensing_config__c testSelectedConfig = new PM_Selected_Dipsensing_config__c();
        testSelectedConfig.Quote_item__c = qli.id;
        testSelectedConfig.Location__c = 'EU';
        testSelectedConfig.Product_Type__c = 'Full Pump (separate actuator)';
        testSelectedConfig.Product_Name__c = 'TEST';
        testSelectedConfig.Cap__c = 'TEST';
        testSelectedConfig.Pack_Name__c ='Test';
        testSelectedConfig.Bottle_Decoration__c ='Test';
        testSelectedConfig.Actuator_Finishing__c = 'TEST';
        testSelectedConfig.Collar__c = 'Test';
        testSelectedConfig.Collar_Finishing__c = 'TEST';
        testSelectedConfig.Cap_Finishing__c = 'Metallization';
        testSelectedConfig.Coloring__c ='Test';
        testSelectedConfig.Actuator__c = 'Test';
        testSelectedConfig.Insert_Type__c = 'Test';
        testSelectedConfig.Dosage__c = '5ml';
        testSelectedConfig.Cap_Type__c = 'Test';
        testSelectedConfig.Diptube_Material__c = 'Optional (Transparent TPX)';
        testSelectedConfig.Colored_Diptube__c = 'test';
        testSelectedConfig.Engine_Neck__c = 'Test';
        testSelectedConfig.Actuator_Finishing__c = 'Metallization';
        testSelectedConfig.Insert_Coloring__c = 'Natural';
        testSelectedConfig.Collar_Finishing__c = 'Metallization';
        testSelectedConfig.Bottle_Finishing__c = 'Metallization';
        testSelectedConfig.Pump_Segmentation__c = 'Test';
        testSelectedConfig.Engine_Neck__c = 'Test';
        testSelectedConfig.Product_segment__c = 'Sampler pumps';
        insert testSelectedConfig;

        PMCalculator_EU_SamplerPump pmCalcEUSamplerPump = new PMCalculator_EU_SamplerPump(testSelectedConfig);
        pmCalcEUSamplerPump.calculate();
	
        PMCalculator_EU_FineMist pmCalcEUFM = new PMCalculator_EU_FineMist(testSelectedConfig);
        pmCalcEUFM.calculate();
        System.assertNotEquals(0, [select Id from PM_Price_Detail__c].size());
        
        
        Test.stopTest();
        
    }
}