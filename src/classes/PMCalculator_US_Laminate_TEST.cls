/**
 * <b>Unit Class Test PMCalculator_US_Laminate_TEST</b>
 * @author EWA
 * @version 1.1 - Assert equals test, refactoring and pretty printing
 * @history 1.1 - Assert equals test, refactoring and pretty printing
 *          1.0 - Initiale Version
 */
@isTest
public class PMCalculator_US_Laminate_TEST {
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
    
        //Create an opportunity for Test purpose
        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
        insert opp;

        //Create a quote for Test purpose
        Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(),
                                date_Quote_Won__c = Date.today(), Status = 'Draft', Skonto_for_cash_payment__c = '3');
        insert q; 
        
        Product_Sub_segment__c prod2 = new Product_Sub_segment__c(
        	Name = 'Iron Lotion pumps'
      	);
      	insert prod2;
        
        //Create a Product2 record for Test Purpose
        Product2 prod = new Product2(Name = 'Laminate Tubes', Family = 'Tubes',	IsActive=true, Product_Sub_Segment__c = prod2.Id);
        insert prod;
        
        //Create a PricebookEntry record for Test Purpose
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
        productSegmentGlobalConfigs.Product_Segment__c = 'Laminate Tubes';
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
        
        //Inset PM_Tubes_Config__c groupe
        PM_Tubes_Config__c groupe = new PM_Tubes_Config__c();
        groupe.GROUPES_1__c = '10_Test';
        groupe.GROUPES_2__c = 10;
        groupe.Location__c='US';         
        insert groupe;
        
        PM_Tubes_Config__c lengthUpcharge =new PM_Tubes_Config__c();
        lengthUpcharge.Location__c = 'US';
        lengthUpcharge.Diameter_mm__c = 10;
        lengthUpcharge.Table_name__c = 'Standard Length';
        lengthUpcharge.STD_LENGTH__c = '10';
        insert lengthUpcharge;
        
        PM_Tubes_Config__c capFeature =new PM_Tubes_Config__c();
        capFeature.Location__c = 'US';
        capFeature.Diameter_inches__c = '2';
        capFeature.Table_name__c = 'CAP FEATURE';
        capFeature.Shrink_band__c = '10';
        capFeature.Hot_Stamping__c = '5';
        insert capFeature;
        
        PM_Tubes_Config__c printEffect =new PM_Tubes_Config__c();
        printEffect.Location__c = 'US';
        printEffect.Table_name__c = 'Print Effect';
        printEffect.Print_Effect_Options__c = 'Test Print';
        insert printEffect;
        
        PM_Tubes_Config__c quality =new PM_Tubes_Config__c();
        quality.Location__c = 'US';
        quality.Table_name__c = 'Quality Upcharge';
        quality.Quality_Level__c = '2';
        quality.Tubes_segment__c = 'Plastic';
        insert quality;
        
        PM_Tubes_Config__c CDI =new PM_Tubes_Config__c();
        CDI.Location__c = 'US';
        CDI.Table_name__c = 'CDI Impact Cap / head';
        CDI.Cap_nb__c = 'TestEurocode';
        CDI.Tubes_segment__c = 'Plastic';
        CDI.Cap_wt__c = '2';
        CDI.Concatenate__c = '2Head_Test';
        CDI.Hd_Wt__c = 5;
        insert CDI;
        
        //PM_Tubes_Pricing__c
        PM_Tubes_Pricing__c testPricing = new PM_Tubes_Pricing__c();
        testPricing.Version__c = 3;
        testPricing.Location__c = 'US';
        testPricing.Tubes_Segments__c = 'Laminate';
        testPricing.X10__c = 5;
        testPricing.X15__c = 5;
        testPricing.X20__c = 5;
        testPricing.X25__c = 5;
        testPricing.X30__c = 5;
        testPricing.X50__c = 5;
		testPricing.X75__c = 5;
        testPricing.X100__c = 5;
        testPricing.X200__c = 5;
        testPricing.X250__c = 5;
        testPricing.X300__c = 5;
        testPricing.X500__c = 5;
        testPricing.Ref__c = '1010TG1STANDARD3-01';        
        insert testPricing;
       
        //PM_Tubes_Pricing__c
        PM_Tubes_Pricing__c testPricing2 = new PM_Tubes_Pricing__c();
        testPricing2.Version__c = 3;
        testPricing2.Location__c = 'US';
        testPricing2.Tubes_Segments__c = 'Laminate';
        testPricing2.X10__c = 5;
        testPricing2.X15__c = 5;
        testPricing2.X20__c = 5;
        testPricing2.X25__c = 5;
        testPricing2.X30__c = 5;
        testPricing2.X50__c = 5;
        testPricing2.X75__c = 5;
        testPricing2.X100__c = 5;
        testPricing2.X200__c = 5;
        testPricing2.X250__c = 5;
        testPricing2.X300__c = 5;
        testPricing2.X500__c = 5;
        testPricing2.Ref__c = 'CURRENT NA2Tube (base listprice)';        
        insert testPricing2;

        //PM_Tubes_Pricing__c
        PM_Tubes_Pricing__c testPricing3 = new PM_Tubes_Pricing__c();
        testPricing3.Version__c = 3;
        testPricing3.Location__c = 'US';
        testPricing3.Tubes_Segments__c = 'Laminate';
        testPricing3.X10__c = 5;
        testPricing3.X15__c = 5;
        testPricing3.X20__c = 5;
        testPricing3.X25__c = 5;
        testPricing3.X30__c = 5;
        testPricing3.X50__c = 5;
        testPricing3.X75__c = 5;
        testPricing3.X100__c = 5;
        testPricing3.X200__c = 5;
        testPricing3.X250__c = 5;
        testPricing3.X300__c = 5;
        testPricing3.X500__c = 5;
        testPricing3.Ref__c = 'CURRENT NA2Length High Density';        
        insert testPricing3;

        //PM_Tubes_Pricing__c
        PM_Tubes_Pricing__c testPricing4 = new PM_Tubes_Pricing__c();
        testPricing4.Version__c = 3;
        testPricing4.Location__c = 'US';
        testPricing4.Tubes_Segments__c = 'Laminate';
        testPricing4.X10__c = 5;
        testPricing4.X15__c = 5;
        testPricing4.X20__c = 5;
        testPricing4.X25__c = 5;
        testPricing4.X30__c = 5;
        testPricing4.X50__c = 5;
        testPricing4.X75__c = 5;
        testPricing4.X100__c = 5;
        testPricing4.X200__c = 5;
        testPricing4.X250__c = 5;
        testPricing4.X300__c = 5;
        testPricing4.X500__c = 5;
        testPricing4.Ref__c = 'CURRENT NA2Head_Test';        
        insert testPricing4;

        //PM_Tubes_Pricing__c
        PM_Tubes_Pricing__c testPricing5 = new PM_Tubes_Pricing__c();
        testPricing5.Version__c = 3;
        testPricing5.Location__c = 'US';
        testPricing5.Tubes_Segments__c = 'Laminate';
        testPricing5.X10__c = 5;
        testPricing5.X15__c = 5;
        testPricing5.X20__c = 5;
        testPricing5.X25__c = 5;
        testPricing5.X30__c = 5;
        testPricing5.X50__c = 5;
        testPricing5.X75__c = 5;
        testPricing5.X100__c = 5;
        testPricing5.X200__c = 5;
        testPricing5.X250__c = 5;
        testPricing5.X300__c = 5;
        testPricing5.X500__c = 5;
        testPricing5.Ref__c = 'CURRENT NA2White/Natural';        
        insert testPricing5;

        //PM_Tubes_Pricing__c
        PM_Tubes_Pricing__c testPricing6 = new PM_Tubes_Pricing__c();
        testPricing6.Version__c = 3;
        testPricing6.Location__c = 'US';
        testPricing6.Tubes_Segments__c = 'Laminate';
        testPricing6.X10__c = 5;
        testPricing6.X15__c = 5;
        testPricing6.X20__c = 5;
        testPricing6.X25__c = 5;
        testPricing6.X30__c = 5;
        testPricing6.X50__c = 5;
        testPricing6.X75__c = 5;
        testPricing6.X100__c = 5;
        testPricing6.X200__c = 5;
        testPricing6.X250__c = 5;
        testPricing6.X300__c = 5;
        testPricing6.X500__c = 5;
        testPricing6.Ref__c = 'CURRENT NA2Yes';        
        insert testPricing6;

        //PM_Tubes_Pricing__c
        PM_Tubes_Pricing__c testPricing7 = new PM_Tubes_Pricing__c();
        testPricing7.Version__c = 3;
        testPricing7.Location__c = 'US';
        testPricing7.Tubes_Segments__c = 'Laminate';
        testPricing7.X10__c = 5;
        testPricing7.X15__c = 5;
        testPricing7.X20__c = 5;
        testPricing7.X25__c = 5;
        testPricing7.X30__c = 5;
        testPricing7.X50__c = 5;
        testPricing7.X75__c = 5;
        testPricing7.X100__c = 5;
        testPricing7.X200__c = 5;
        testPricing7.X250__c = 5;
        testPricing7.X300__c = 5;
        testPricing7.X500__c = 5;
        testPricing7.Ref__c = 'CURRENT NA2High Density';        
        insert testPricing7;

        //PM_Tubes_Pricing__c
        PM_Tubes_Pricing__c testPricing8 = new PM_Tubes_Pricing__c();
        testPricing8.Version__c = 3;
        testPricing8.Location__c = 'US';
        testPricing8.Tubes_Segments__c = 'Laminate';
        testPricing8.X10__c = 5;
        testPricing8.X15__c = 5;
        testPricing8.X20__c = 5;
        testPricing8.X25__c = 5;
        testPricing8.X30__c = 5;
        testPricing8.X50__c = 5;
        testPricing8.X75__c = 5;
        testPricing8.X100__c = 5;
        testPricing8.X200__c = 5;
        testPricing8.X250__c = 5;
        testPricing8.X300__c = 5;
        testPricing8.X500__c = 5;
        testPricing8.Ref__c = 'TESTEUROCODESTANDARD COLOR';        
        insert testPricing8;

        //PM_Tubes_Pricing__c
        PM_Tubes_Pricing__c testPricing9 = new PM_Tubes_Pricing__c();
        testPricing9.Version__c = 3;
        testPricing9.Location__c = 'US';
        testPricing9.Tubes_Segments__c = 'Laminate';
        testPricing9.X10__c = 5;
        testPricing9.X15__c = 5;
        testPricing9.X20__c = 5;
        testPricing9.X25__c = 5;
        testPricing9.X30__c = 5;
        testPricing9.X50__c = 5;
        testPricing9.X75__c = 5;
        testPricing9.X100__c = 5;
        testPricing9.X200__c = 5;
        testPricing9.X250__c = 5;
        testPricing9.X300__c = 5;
        testPricing9.X500__c = 5;
        testPricing9.Ref__c = 'CAP_FEATURE_PRICE_Yes_2';        
        insert testPricing9;

        //PM_Tubes_Pricing__c
        PM_Tubes_Pricing__c testPricing10 = new PM_Tubes_Pricing__c();
        testPricing10.Version__c = 3;
        testPricing10.Location__c = 'US';
        testPricing10.Tubes_Segments__c = 'Laminate';
        testPricing10.X10__c = 5;
        testPricing10.X15__c = 5;
        testPricing10.X20__c = 5;
        testPricing10.X25__c = 5;
        testPricing10.X30__c = 5;
        testPricing10.X50__c = 5;
        testPricing10.X75__c = 5;
        testPricing10.X100__c = 5;
        testPricing10.X200__c = 5;
        testPricing10.X250__c = 5;
        testPricing10.X300__c = 5;
        testPricing10.X500__c = 5;
        testPricing10.Ref__c = 'CURRENT NA2Offset 5';        
        insert testPricing10;
        //  insert testSelectedConfig;
        PM_Selected_Tubes_Config__c testSelectConfig = new PM_Selected_Tubes_Config__c();
        testSelectConfig.Quote_item__c = qli.id;
        testSelectConfig.Product_segment__c = 'Laminate Tubes';
        testSelectConfig.Location__c = 'US';
        testSelectConfig.Diameter_inches__c = '2';
        testSelectConfig.Shape__c = 'Cylindrical';
        testSelectConfig.Head_Name__c = 'Head_Test';
        testSelectConfig.Sleeve_type__c = 'Sleeve_Test';
        testSelectConfig.Sleeve_Color__c = 'Sleeve_Color_Test';
        testSelectConfig.Specific_Length_inches__c = '5';
        testSelectConfig.Sleeve_Material_Mix__c = 'High Density';
        testSelectConfig.Peel_Seal__c = 'Yes';
        testSelectConfig.Consigned_Cap__c = 'NO';
        testSelectConfig.Manual_Capping__c = 'Yes';
        testSelectConfig.Cap_Hot_Stamping__c = 'Yes';
        testSelectConfig.Shrink_band__c = 'Yes';
        testSelectConfig.Printing_type__c = 'SILKSCREEN';
        testSelectConfig.NB_Offset_Colors__c = 5;
        testSelectConfig.NB_Flexo_Colors__c = 5;
        testSelectConfig.Deco_Hot_Stamping__c = 'Yes';
        testSelectConfig.Coating__c = 'Matte';
        testSelectConfig.UV_Inhibitor__c = 'Yes';
        testSelectConfig.Double_Pigment__c = 'Yes';
        testSelectConfig.Pallet__c = 'Heat Treated Wooden Pallet';
        testSelectConfig.Polybag__c = 'Yes';
        testSelectConfig.Quality_Level__c = '2';
        testSelectConfig.Number_of_ref_per_run__c = 2;
        testSelectConfig.Number_of_tubes_per_artwork_in_Ku__c = 5;
        testSelectConfig.Cap_Eurocode__c ='TestEurocode';
        testSelectConfig.Printing_Effects__c = '360 degree';
        testSelectConfig.Cap_Name__c='Cap';
        testSelectConfig.Incoterm__c = 'test';
        testSelectConfig.Sleeve_Length_inches__c='5';
        testSelectConfig.Head_Color__c='White';
        testSelectConfig.Rondelle__c='Yes';
        testSelectConfig.NB_SS_Colors__c=2;
        testSelectConfig.Hologram__c='Yes';
        testSelectConfig.Cold_Stamping__c='Yes';
        testSelectConfig.Polysheet__c='Yes';
		testSelectConfig.Resin_Index__c=2;       
        insert testSelectConfig;

        PMCalculator_US_Laminate pmCalcUSLaminate = new PMCalculator_US_Laminate(testSelectConfig);
        pmCalcUSLaminate.calculate();

        //ALE Coverage error
        Double resultconvert = PMCalculator_US_Laminate.convertLengthFractionToDecimal('1 1/2');
        system.assertEquals(resultconvert, 1.5);


        Test.stopTest();
    }
}