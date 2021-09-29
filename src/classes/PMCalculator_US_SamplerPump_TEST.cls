/**
 * <b>Unit Test Class PMCalculator_US_SamplerPump_TEST</b>
 * @author EWA
 * @version 1.0 - Initial Version
 * @history 1.0 - Initial Version
 */
@isTest
public class PMCalculator_US_SamplerPump_TEST {
    /**
     * [testMethod1 description]
     */	
    @isTest
    static void testMethod1(){       
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
    
        //Create an Opportunity for test purpose
        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
        insert opp;
    
        //Create a quote for test purpose
        Quote q = new Quote(pricebook2Id = pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), 
                                date_Quote_Won__c = Date.today(), Status = 'Draft', Skonto_for_cash_payment__c =' 3');
        insert q; 
        
        Product_Sub_segment__c prod2 = new Product_Sub_segment__c(
        	Name = 'Iron Lotion pumps'
      	);
      	insert prod2;
        
        //Create a Product2 record for test purpose
        Product2 prod = new Product2(Name = 'Sampler pumps', Family = 'Bottle', IsActive=true, Product_Sub_Segment__c = prod2.Id);
        insert prod;
     
        //Create a PricebookEntry record for test purpose
     	PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;

    	//Insert QLI
        QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0, Quantity = 100, PricebookEntryId = standardPrice.id, Product2Id = prod.id, QuoteId = q.Id, Ref_RFQ__c = 'Test');        
        qli.Market_Of_Application__c = 'BODY CARE';
        qli.Customer_Type__c = 'Brand Owner';
        qli.Location__c = 'US';
        qli.Customer_end_of_year_rebate__c = 'Yes (1%)';
        insert qli;
 
        //Create Price Details
        List<PM_price_detail__c> priceDetails = new list<PM_price_detail__c>();        
        for(integer i=1; i<=4; i++){            
            PM_price_detail__c newPriceDetails = new PM_price_detail__c();
            newPriceDetails.Quote_item__c = qli.id;
            newPriceDetails.MOQ_Min__c = 10;
            newPriceDetails.MOQ_Max__c = 20;
            newPriceDetails.List_Price__c = i+10.50;
            newPriceDetails.Name = 'test'+i;            
            priceDetails.add(newPriceDetails);
        }
        insert priceDetails;
        
        //Arthur Leriche : Insert PM_Dispensing_Pricing
        PM_Dispensing_Pricing__c newpricingInsertType = new PM_Dispensing_Pricing__c(Ref__c = 'Full Pump (separate actuator)_TEST_Test_Test',
                                                                               X10__c = 15,
                                                                               Product_Segment__c = 'Sampler Pumps',
                                                                               Location__c ='US',
                                                                               Version__c = 1);
        
        insert newpricingInsertType;

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
        productSegmentGlobalConfigs.Product_Segment__c = 'Sampler pumps';
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
        PM_Selected_Dipsensing_config__c testSelectedConfig = new PM_Selected_Dipsensing_config__c();
        testSelectedConfig.Quote_item__c = qli.id;
        testSelectedConfig.Location__c = 'US';
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
        insert testSelectedConfig;

        PMCalculator_US_SamplerPump pmCalcUSSamplerPump = new PMCalculator_US_SamplerPump(testSelectedConfig);
        pmCalcUSSamplerPump.calculate();
        
        //Arthur Leriche test Calculate Insert Type
       	Decimal aTester;
        for(PM_Price_Detail__c pricedetail : pmCalcUSSamplerPump.listDetailsToUpsert){
            if(pricedetail.Name == 'Insert Type' && pricedetail.MOQ_Min__c == 10){
                aTester = pricedetail.List_Price__c;
            }
        }
        system.assertEquals(aTester, 0);

        Test.stopTest();
        
    }
    
    
    
        @isTest
    static void testMethod2(){       
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
    
        //Create an Opportunity for test purpose
        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
        insert opp;
    
        //Create a quote for test purpose
        Quote q = new Quote(pricebook2Id = pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), 
                                date_Quote_Won__c = Date.today(), Status = 'Draft', Skonto_for_cash_payment__c =' 3');
        insert q; 
        
        Product_Sub_segment__c prod2 = new Product_Sub_segment__c(
        	Name = 'Iron Lotion pumps'
      	);
      	insert prod2;
        
        //Create a Product2 record for test purpose
        Product2 prod = new Product2(Name = 'Sampler pumps', Family = 'Bottle', IsActive=true, Product_Sub_Segment__c = prod2.Id);
        insert prod;
     
        //Create a PricebookEntry record for test purpose
     	PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;

    	//Insert QLI
        QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0, Quantity = 100, PricebookEntryId = standardPrice.id, Product2Id = prod.id, QuoteId = q.Id, Ref_RFQ__c = 'Test');        
        qli.Market_Of_Application__c = 'BODY CARE';
        qli.Customer_Type__c = 'Brand Owner';
        qli.Location__c = 'US';
        qli.Customer_end_of_year_rebate__c = 'Yes (1%)';
        insert qli;
 
        //Create Price Details
        List<PM_price_detail__c> priceDetails = new list<PM_price_detail__c>();        
        for(integer i=1; i<=4; i++){            
            PM_price_detail__c newPriceDetails = new PM_price_detail__c();
            newPriceDetails.Quote_item__c = qli.id;
            newPriceDetails.MOQ_Min__c = 10;
            newPriceDetails.MOQ_Max__c = 20;
            newPriceDetails.List_Price__c = i+10.50;
            newPriceDetails.Name = 'test'+i;            
            priceDetails.add(newPriceDetails);
        }
        insert priceDetails;
        
        //Arthur Leriche : Insert PM_Dispensing_Pricing
        PM_Dispensing_Pricing__c newpricingInsertType = new PM_Dispensing_Pricing__c(Ref__c = 'TESTTestTest',
                                                                               X10__c = 15,
                                                                               Product_Segment__c = 'Sampler Pumps',
                                                                               Location__c ='US',
                                                                               Version__c = 1,
                                                                                    Valid_From__c = Date.today(),
                                                                                    Valid_To__c = Date.today().addDays(5));
         PM_Dispensing_Pricing__c newpricingInsertType1 = new PM_Dispensing_Pricing__c(Ref__c = 'TEST_null__null',
                                                                               X10__c = 15,
                                                                               Product_Segment__c = 'Sampler Pumps',
                                                                               Location__c ='US',
                                                                               Version__c = 1,
                                                                                    Valid_From__c = Date.today(),
                                                                                    Valid_To__c = Date.today().addDays(5));
         PM_Dispensing_Pricing__c newpricingInsertType2 = new PM_Dispensing_Pricing__c(Ref__c = 'TEST_Test_TEST',
                                                                               X10__c = 15,
                                                                               Product_Segment__c = 'Sampler Pumps',
                                                                               Location__c ='US',
                                                                               Version__c = 1,
                                                                                    Valid_From__c = Date.today(),
                                                                                    Valid_To__c = Date.today().addDays(5));
         PM_Dispensing_Pricing__c newpricingInsertType3 = new PM_Dispensing_Pricing__c(Ref__c = 'TESTPumpPump Metallization',
                                                                               X10__c = 15,
                                                                               Product_Segment__c = 'Sampler Pumps',
                                                                               Location__c ='US',
                                                                               Version__c = 1,
                                                                                    Valid_From__c = Date.today(),
                                                                                    Valid_To__c = Date.today().addDays(5));
         PM_Dispensing_Pricing__c newpricingInsertType4 = new PM_Dispensing_Pricing__c(Ref__c = 'TESTinsertStd',
                                                                               X10__c = 15,
                                                                               Product_Segment__c = 'Sampler Pumps',
                                                                               Location__c ='US',
                                                                               Version__c = 1,
                                                                                    Valid_From__c = Date.today(),
                                                                                    Valid_To__c = Date.today().addDays(5));
        PM_Dispensing_Pricing__c newpricingInsertType5 = new PM_Dispensing_Pricing__c(Ref__c = 'TESTCollarCollar Metallization',
                                                                               X10__c = 15,
                                                                               Product_Segment__c = 'Sampler Pumps',
                                                                               Location__c ='US',
                                                                               Version__c = 1,
                                                                                    Valid_From__c = Date.today(),
                                                                                    Valid_To__c = Date.today().addDays(5));
        PM_Dispensing_Pricing__c newpricingInsertType6 = new PM_Dispensing_Pricing__c(Ref__c = 'TESTCapMetallization',
                                                                               X10__c = 15,
                                                                               Product_Segment__c = 'Sampler Pumps',
                                                                               Location__c ='US',
                                                                               Version__c = 1,
                                                                                    Valid_From__c = Date.today(),
                                                                                    Valid_To__c = Date.today().addDays(5));
        PM_Dispensing_Pricing__c newpricingInsertType7 = new PM_Dispensing_Pricing__c(Ref__c = 'TESTBottleMetallization',
                                                                               X10__c = 15,
                                                                               Product_Segment__c = 'Sampler Pumps',
                                                                               Location__c ='US',
                                                                               Version__c = 1,
                                                                                    Valid_From__c = Date.today(),
                                                                                    Valid_To__c = Date.today().addDays(5));
        PM_Dispensing_Pricing__c newpricingInsertType8 = new PM_Dispensing_Pricing__c(Ref__c = 'TESTnullBottleTestMetal',
                                                                               X10__c = 15,
                                                                               Product_Segment__c = 'Sampler Pumps',
                                                                               Location__c ='US',
                                                                               Version__c = 1,
                                                                                    Valid_From__c = Date.today(),
                                                                                    Valid_To__c = Date.today().addDays(5));
        PM_Dispensing_Pricing__c newpricingInsertType9 = new PM_Dispensing_Pricing__c(Ref__c = 'Full Pump (separate actuator)_TEST_Test_Test',
                                                                               X10__c = 15,
                                                                               Product_Segment__c = 'Sampler Pumps',
                                                                               Location__c ='US',
                                                                               Version__c = 1,
                                                                                    Valid_From__c = Date.today(),
                                                                                    Valid_To__c = Date.today().addDays(5));
        
        insert new List<PM_Dispensing_Pricing__c>{newpricingInsertType,newpricingInsertType1,newpricingInsertType2,newpricingInsertType3,newpricingInsertType4,newpricingInsertType5,newpricingInsertType6,newpricingInsertType7,newpricingInsertType8,newpricingInsertType9};

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
        productSegmentGlobalConfigs.Product_Segment__c = 'Sampler pumps';
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
        PM_Selected_Dipsensing_config__c testSelectedConfig = new PM_Selected_Dipsensing_config__c();
        testSelectedConfig.Quote_item__c = qli.id;
        testSelectedConfig.Location__c = 'US';
        testSelectedConfig.Product_Type__c = 'Full Pump (separate actuator)';
        testSelectedConfig.Product_Name__c = 'TEST';
        testSelectedConfig.Cap__c = 'TEST';
        testSelectedConfig.Product_segment__c = 'Sampler pumps';
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
        insert testSelectedConfig;

        PMCalculator_US_SamplerPump pmCalcUSSamplerPump = new PMCalculator_US_SamplerPump(testSelectedConfig);
        pmCalcUSSamplerPump.calculate();
        
        //Arthur Leriche test Calculate Insert Type
       	Decimal aTester;
        for(PM_Price_Detail__c pricedetail : pmCalcUSSamplerPump.listDetailsToUpsert){
            if(pricedetail.Name == 'Insert Type' && pricedetail.MOQ_Min__c == 10){
                aTester = pricedetail.List_Price__c;
            }
        }
        system.assertEquals(aTester, 15);

        Test.stopTest();
        
    }
    
    
    
    
    
    
    
    
    

}