/**
 * <b>Unit Class Test PMCalculator_EU_Lotion_Test </b>
 */
@isTest
private class PMCalculator_EU_Lotion_Test {
	//Methods of the class PMCalculator_EU_Lotion_Test
	/**
	 * [testMethod1 description : will ensure the code coverage for the classe PMCalculator_EU_Lotion]
	 */
	@isTest 
	static void testMethod1() {
		
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
        qli.DS_Skonto_for_cash_payment__c='Yes (1%)';
       
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
        
      
        PM_Dispensing_Pricing__c testPricing = new PM_Dispensing_Pricing__c();
        testPricing.Version__c = 3;
        testPricing.Location__c = 'EU';
        testPricing.Product_Segment__c = 'Lotion pumps';
        testPricing.X10__c = 5;
        testPricing.X15__c = 5;
        testPricing.X20__c = 5;
        testPricing.X25__c = 5;
        testPricing.Ref__c = 'Complete Pack_D.N.Airless ø41_SP34D_ELITE_CRIMP ON_0_yes_NULL_TEST_TEST';   
        testPricing.Valid_From__c = Date.today();
        testPricing.Valid_To__c = Date.today().addDays(30);     
        insert testPricing;

        PM_Dispensing_Pricing__c testPricing2 = new PM_Dispensing_Pricing__c();
        testPricing2.Version__c = 3;
        testPricing2.Location__c = 'EU';
        testPricing2.Product_Segment__c = 'Lotion pumps';
        testPricing2.X10__c = 5;
        testPricing2.X15__c = 5;
        testPricing2.X20__c = 5;
        testPricing2.X25__c = 5;
        testPricing2.Ref__c = 'yes';   
        testPricing2.Valid_From__c = Date.today();
        testPricing2.Valid_To__c = Date.today().addDays(30);     
        insert testPricing2;

        PM_Dispensing_Pricing__c testPricing3 = new PM_Dispensing_Pricing__c();
        testPricing3.Version__c = 3;
        testPricing3.Location__c = 'EU';
        testPricing3.Product_Segment__c = 'Lotion pumps';
        testPricing3.X10__c = 5;
        testPricing3.X15__c = 5;
        testPricing3.X20__c = 5;
        testPricing3.X25__c = 5;
        testPricing3.Ref__c = 'SP34D_Elite_TEST';   
        testPricing3.Valid_From__c = Date.today();
        testPricing3.Valid_To__c = Date.today().addDays(30);     
        insert testPricing3;

        PM_Dispensing_Pricing__c testPricing4 = new PM_Dispensing_Pricing__c();
        testPricing4.Version__c = 3;
        testPricing4.Location__c = 'EU';
        testPricing4.Product_Segment__c = 'Lotion pumps';
        testPricing4.X10__c = 5;
        testPricing4.X15__c = 5;
        testPricing4.X20__c = 5;
        testPricing4.X25__c = 5;
        testPricing4.Ref__c = 'D.N.Airless ø41_Test_Le Tréport';   
        testPricing4.Valid_From__c = Date.today();
        testPricing4.Valid_To__c = Date.today().addDays(30);     
        insert testPricing4;

        PM_Dispensing_Pricing__c testPricing5 = new PM_Dispensing_Pricing__c();
        testPricing5.Version__c = 3;
        testPricing5.Location__c = 'EU';
        testPricing5.Product_Segment__c = 'Lotion pumps';
        testPricing5.X10__c = 5;
        testPricing5.X15__c = 5;
        testPricing5.X20__c = 5;
        testPricing5.X25__c = 5;
        testPricing5.Ref__c = 'SP34D_Elite_TEST_Actuator color';   
        testPricing5.Valid_From__c = Date.today();
        testPricing5.Valid_To__c = Date.today().addDays(30);     
        insert testPricing5;

        PM_Dispensing_Pricing__c testPricing6 = new PM_Dispensing_Pricing__c();
        testPricing6.Version__c = 3;
        testPricing6.Location__c = 'EU';
        testPricing6.Product_Segment__c = 'Lotion pumps';
        testPricing6.X10__c = 5;
        testPricing6.X15__c = 5;
        testPricing6.X20__c = 5;
        testPricing6.X25__c = 5;
        testPricing6.Ref__c = 'SP34D_Elite_TEST_Collar color';   
        testPricing6.Valid_From__c = Date.today();
        testPricing6.Valid_To__c = Date.today().addDays(30);     
        insert testPricing6;

        PM_Dispensing_Pricing__c testPricing7 = new PM_Dispensing_Pricing__c();
        testPricing7.Version__c = 3;
        testPricing7.Location__c = 'EU';
        testPricing7.Product_Segment__c = 'Lotion pumps';
        testPricing7.X10__c = 5;
        testPricing7.X15__c = 5;
        testPricing7.X20__c = 5;
        testPricing7.X25__c = 5;
        testPricing7.Ref__c = 'SP34D_Elite_TEST_Cap color';   
        testPricing7.Valid_From__c = Date.today();
        testPricing7.Valid_To__c = Date.today().addDays(30);     
        insert testPricing7;

        PM_Dispensing_Pricing__c testPricing8 = new PM_Dispensing_Pricing__c();
        testPricing8.Version__c = 3;
        testPricing8.Location__c = 'EU';
        testPricing8.Product_Segment__c = 'Lotion pumps';
        testPricing8.X10__c = 5;
        testPricing8.X15__c = 5;
        testPricing8.X20__c = 5;
        testPricing8.X25__c = 5;
        testPricing8.Ref__c = 'nullTESTnull';   
        testPricing8.Valid_From__c = Date.today();
        testPricing8.Valid_To__c = Date.today().addDays(30);     
        insert testPricing8;

        PM_Dispensing_Pricing__c testPricing9 = new PM_Dispensing_Pricing__c();
        testPricing9.Version__c = 3;
        testPricing9.Location__c = 'EU';
        testPricing9.Product_Segment__c = 'Lotion pumps';
        testPricing9.X10__c = 5;
        testPricing9.X15__c = 5;
        testPricing9.X20__c = 5;
        testPricing9.X25__c = 5;
        testPricing9.Ref__c = 'null_null';   
        testPricing9.Valid_From__c = Date.today();
        testPricing9.Valid_To__c = Date.today().addDays(30);     
        insert testPricing9;

        PM_Dispensing_Pricing__c testPricing10 = new PM_Dispensing_Pricing__c();
        testPricing10.Version__c = 3;
        testPricing10.Location__c = 'EU';
        testPricing10.Product_Segment__c = 'Lotion pumps';
        testPricing10.X10__c = 5;
        testPricing10.X15__c = 5;
        testPricing10.X20__c = 5;
        testPricing10.X25__c = 5;
        testPricing10.Ref__c = 'SP34DNullNullCollar Hot stamping band';   
        testPricing10.Valid_From__c = Date.today();
        testPricing10.Valid_To__c = Date.today().addDays(30);     
        insert testPricing10;

        PM_Dispensing_Pricing__c testPricing11 = new PM_Dispensing_Pricing__c();
        testPricing11.Version__c = 3;
        testPricing11.Location__c = 'EU';
        testPricing11.Product_Segment__c = 'Lotion pumps';
        testPricing11.X10__c = 5;
        testPricing11.X15__c = 5;
        testPricing11.X20__c = 5;
        testPricing11.X25__c = 5;
        testPricing11.Ref__c = 'null_Test_null';   
        testPricing11.Valid_From__c = Date.today();
        testPricing11.Valid_To__c = Date.today().addDays(30);     
        insert testPricing11;
        
        PM_Dispensing_Pricing__c testPricing12 = new PM_Dispensing_Pricing__c();
        testPricing12.Version__c = 3;
        testPricing12.Location__c = 'EU';
        testPricing12.Product_Segment__c = 'Lotion pumps';
        testPricing12.X10__c = 5;
        testPricing12.X15__c = 5;
        testPricing12.X20__c = 5;
        testPricing12.X25__c = 5;
        testPricing12.Ref__c = 'Complete Pack_D.N.Airless ø41_SP34D_ELITE_CRIMP ON_0_W/O_NULL_TEST_TEST';   
        testPricing12.Valid_From__c = Date.today();
        testPricing12.Valid_To__c = Date.today().addDays(30);     
        insert testPricing12;
        
        PM_Dispensing_Pricing__c testPricing13 = new PM_Dispensing_Pricing__c();
        testPricing13.Version__c = 3;
        testPricing13.Location__c = 'EU';
        testPricing13.Product_Segment__c = 'Lotion pumps';
        testPricing13.X10__c = 5;
        testPricing13.X15__c = 5;
        testPricing13.X20__c = 5;
        testPricing13.X25__c = 5;
        testPricing13.Ref__c = 'SP34D_INSERT COLOR';   
        testPricing13.Valid_From__c = Date.today();
        testPricing13.Valid_To__c = Date.today().addDays(30);     
        insert testPricing13;
        
        PM_Dispensing_Pricing__c testPricing14 = new PM_Dispensing_Pricing__c();
        testPricing14.Version__c = 3;
        testPricing14.Location__c = 'EU';
        testPricing14.Product_Segment__c = 'Lotion pumps';
        testPricing14.X10__c = 5;
        testPricing14.X15__c = 5;
        testPricing14.X20__c = 5;
        testPricing14.X25__c = 5;
        testPricing14.Ref__c = 'PBT_BODY_SP34D';   
        testPricing14.Valid_From__c = Date.today();
        testPricing14.Valid_To__c = Date.today().addDays(30);     
        insert testPricing14;
        
        PM_Dispensing_Pricing__c testPricing15 = new PM_Dispensing_Pricing__c();
        testPricing15.Version__c = 3;
        testPricing15.Location__c = 'EU';
        testPricing15.Product_Segment__c = 'Lotion pumps';
        testPricing15.X10__c = 5;
        testPricing15.X15__c = 5;
        testPricing15.X20__c = 5;
        testPricing15.X25__c = 5;
        testPricing15.Ref__c = 'Sleevage_SP34D';   
        testPricing15.Valid_From__c = Date.today();
        testPricing15.Valid_To__c = Date.today().addDays(30);     
        insert testPricing15;
        
        PM_Dispensing_Pricing__c testPricing16 = new PM_Dispensing_Pricing__c();
        testPricing16.Version__c = 3;
        testPricing16.Location__c = 'EU';
        testPricing16.Product_Segment__c = 'Lotion pumps';
        testPricing16.X10__c = 5;
        testPricing16.X15__c = 5;
        testPricing16.X20__c = 5;
        testPricing16.X25__c = 5;
        testPricing16.Ref__c = 'Diptube length_SP34D';   
        testPricing16.Valid_From__c = Date.today();
        testPricing16.Valid_To__c = Date.today().addDays(30);     
        insert testPricing16;
        
        PM_Dispensing_Pricing__c testPricing17 = new PM_Dispensing_Pricing__c();
        testPricing17.Version__c = 3;
        testPricing17.Location__c = 'EU';
        testPricing17.Product_Segment__c = 'Lotion pumps';
        testPricing17.X10__c = 5;
        testPricing17.X15__c = 5;
        testPricing17.X20__c = 5;
        testPricing17.X25__c = 5;
        testPricing17.Ref__c = 'D.N.AIRLESS Ø41_YES_DECORATION';   
        testPricing17.Valid_From__c = Date.today();
        testPricing17.Valid_To__c = Date.today().addDays(30);     
        insert testPricing17;
        
        PM_Dispensing_Pricing__c testPricing18 = new PM_Dispensing_Pricing__c();
        testPricing18.Version__c = 3;
        testPricing18.Location__c = 'EU';
        testPricing18.Product_Segment__c = 'Lotion pumps';
        testPricing18.X10__c = 5;
        testPricing18.X15__c = 5;
        testPricing18.X20__c = 5;
        testPricing18.X25__c = 5;
        testPricing18.Ref__c = 'D.N.AIRLESS Ø41_OK_DECORATION';   
        testPricing18.Valid_From__c = Date.today();
        testPricing18.Valid_To__c = Date.today().addDays(30);     
        insert testPricing18;
        
        PM_Dispensing_Pricing__c testPricing19 = new PM_Dispensing_Pricing__c();
        testPricing19.Version__c = 3;
        testPricing19.Location__c = 'EU';
        testPricing19.Product_Segment__c = 'Lotion pumps';
        testPricing19.X10__c = 5;
        testPricing19.X15__c = 5;
        testPricing19.X20__c = 5;
        testPricing19.X25__c = 5;
        testPricing19.Ref__c = 'D.N.AIRLESS Ø41_Test_DECORATION';   
        testPricing19.Valid_From__c = Date.today();
        testPricing19.Valid_To__c = Date.today().addDays(30);     
        insert testPricing19;
        
        PM_Dispensing_Pricing__c testPricing20 = new PM_Dispensing_Pricing__c();
        testPricing20.Version__c = 3;
        testPricing20.Location__c = 'EU';
        testPricing20.Product_Segment__c = 'Lotion pumps';
        testPricing20.X10__c = 5;
        testPricing20.X15__c = 5;
        testPricing20.X20__c = 5;
        testPricing20.X25__c = 5;
        testPricing20.Ref__c = 'Premia';   
        testPricing20.Valid_From__c = Date.today();
        testPricing20.Valid_To__c = Date.today().addDays(30);     
        insert testPricing20;
        
    PM_Dispensing_Pricing__c testPricing21 = new PM_Dispensing_Pricing__c();
        testPricing20.Version__c = 3;
        testPricing20.Location__c = 'EU';
        testPricing20.Product_Segment__c = 'Lotion pumps';
        testPricing20.X10__c = 5;
        testPricing20.X15__c = 5;
        testPricing20.X20__c = 5;
        testPricing20.X25__c = 5;
        testPricing20.Ref__c = 'SP34D_Complete Pack_D.N.Airless ø41_PP_Test_Yes';   
        testPricing20.Valid_From__c = Date.today();
        testPricing20.Valid_To__c = Date.today().addDays(30);     
        insert testPricing21;
        
        //SP34D_Complete Pack_D.N.Airless ø41_PP_Test_Yes
             
        //  insert testSelectedConfig;
        PM_Selected_Dipsensing_config__c testSelectedConfig = new PM_Selected_Dipsensing_config__c();
        testSelectedConfig.Quote_item__c = qli.id;
        testSelectedConfig.Location__c = 'EU';
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
        testSelectedConfig.Insert_finishing__c = 'Non Standard';
        testSelectedConfig.PBT_Body__c = 'Yes - extra cost'; 
        testSelectedConfig.Plastic_Protection__c = 'Plastic Protection';
        testSelectedConfig.Diptube_Length__c = 'Long tube length (>120mm)';
        testSelectedConfig.Hot_Stamping__c = 'Yes';
        testSelectedConfig.Offset__c = 'OK';
        testSelectedConfig.Silk_Screening__c = 'Test';
        testSelectedConfig.Ring_Coloration__c = 'Non Standard (Colored)';
        testSelectedConfig.Bottle_Material__c='PP';//SP34D_Complete Pack_D.N.Airless ø41_PP_Test_Elite_Crimp On_Test_Test_TEST
		testSelectedConfig.Collar_Decoration__c= 'Test';//SP34D_Complete Pack_D.N.Airless ø41_PP_Test_Elite_Test_TEST_Test
		testSelectedConfig.Cap_Decoration__c= 'Test';// SP34D_Complete Pack_D.N.Airless ø41_PP_Test_Elite_Crimp On_TEST_Test
        testSelectedConfig.Insert_Coloring__c= 'Test';//SP34D_Complete Pack_D.N.Airless ø41_PP_Test_Elite_Crimp On_TEST_Test
       
        insert testSelectedConfig;   
           
        AP00_LotionLeadTime.calcLotionLeadTime(testSelectedConfig);

        PMCalculator_EU_Lotion pmCalcEULotion = new PMCalculator_EU_Lotion(testSelectedConfig);
        pmCalcEULotion.calculate();
        System.assertNotEquals(0, [select Id from PM_Price_Detail__c].size());
        Test.stopTest();
	}
}