/**
 * <b>Unit Test Class PMCalculator_EU_Purefoil_TEST</b>
 * @author Eric Wartelle
 * @version 1.1 - AssertEqual & Pretty Printing
 * @history 1.1 - AssertEqual & Pretty Printing
 *          1.0 - Initiale Version
 */
@isTest
public class PMCalculator_EU_Purefoil_TEST {
    //Methods of the class PMCalculator_EU_Purefoil_TEST
    /**
     * [testMethod1 description]
     */
    @isTest
    static void testMethod1(){
        //Create Test Data
        Country__c country = TestFactory.getGermany();
        insert country;

        //Create Test Distribution Channel
        Distribution_Channel__c testDistrib = new Distribution_Channel__c(Name = 'Test', Distribution_Channel_Code__c = 'test', Language_Key__c = 'test');
        insert testDistrib;

        //Create Sales Area
        Sales_Area__c testArea = new Sales_Area__c(Name='Test', Customer_Size__c='GA');
        insert testArea;

        //Create Test Accounts
        //Account acc = new Account(Name = 'Test Acc 1'+datetime.now(), Country__c = country.Id, Distribution_Channel__c =testDistrib.id,
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
                date_Quote_Won__c=Date.today(),  Status='Draft',Skonto_for_cash_payment__c='3');
        insert q;

        Product_Sub_segment__c prod2 = new Product_Sub_segment__c(
                Name = 'Iron Lotion pumps'
        );
        insert prod2;

        //Create a Product2 record for Test purpose
        Product2 prod = new Product2(Name = 'Plastic Tubes', Family = 'Tubes',	IsActive=true, Product_Sub_Segment__c = prod2.Id);
        insert prod;

        //Create a PricebookEntry for Test purpose
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        //Insert QLI
        QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0, Quantity = 100, PricebookEntryId= standardPrice.id,
                Product2Id = prod.id, QuoteId = q.Id, ID_Calculette__c='PM', Ref_RFQ__c = 'Test');
        qli.Market_Of_Application__c = 'BODY CARE';
        qli.Customer_Type__c = 'Brand Owner';
        qli.Location__c = 'EU';
        qli.Customer_end_of_year_rebate__c = 'Yes (1%)';
        qli.Purefoil_Segment__c = true;
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

        //Assert test
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
        productSegmentGlobalConfigs.Product_Segment__c = 'Purefoil Tubes';
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

        //Insert PM_Tubes_Config__c groupe
        PM_Tubes_Config__c groupe = new PM_Tubes_Config__c();
        groupe.GROUPES_1__c = '10_Test';
        groupe.GROUPES_2__c = 10;
        groupe.Location__c='EU';
        groupe.Tubes_segment__c = 'Purefoil';
        insert groupe;


        PM_Tubes_Config__c lengthUpcharge =new PM_Tubes_Config__c();
        lengthUpcharge.Location__c = 'EU';
        lengthUpcharge.Diameter_mm__c = 10;
        lengthUpcharge.Table_name__c = 'Standard Length';
        lengthUpcharge.STD_LENGTH__c = '10';
        insert lengthUpcharge;

        PM_Tubes_Config__c Platts =new PM_Tubes_Config__c();
        Platts.Location__c = 'EU';
        Platts.Diameter_mm__c = 10;
        Platts.Table_name__c = 'Platts';
        Platts.Platts_Poids_Jupe_nets__c = 10;
        Platts.Platts_Poids_tete__c =10;
        Platts.Platts_bouchon__c = 10;
        Platts.Tubes_segment__c = 'Plastic';
        insert Platts;

        //PM_Tubes_Pricing__c
        PM_Tubes_Pricing__c testPricing = new PM_Tubes_Pricing__c();
        testPricing.Version__c = 3;
        testPricing.Location__c = 'EU';
        testPricing.Tubes_Segments__c = 'Plastic';
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
        
        //Add By Zak
        PM_Tubes_Pricing__c testPricing1 = new PM_Tubes_Pricing__c(Ref__c = '1010TG1Test1-01',
                                                                   X10__c = 15,
                                                                   Tubes_Segments__c = 'Purefoil',
                                                                   Location__c = 'EU',
                                                                   Version__c = 3,
                                                                   Valid_From__c = Date.today(),
                                                                   Valid_To__c = Date.today().addDays(5));
        PM_Tubes_Pricing__c testPricing2 = new PM_Tubes_Pricing__c(Ref__c = '1010TG1standard4-06',
                                                                   X10__c = 15,
                                                                   Tubes_Segments__c = 'Purefoil',
                                                                   Location__c = 'EU',
                                                                   Version__c = 3,
                                                                   Valid_From__c = Date.today(),
                                                                   Valid_To__c = Date.today().addDays(5));
        PM_Tubes_Pricing__c testPricing3 = new PM_Tubes_Pricing__c(Ref__c = '1010TG1standard',
                                                                   X10__c = 15,
                                                                   Tubes_Segments__c = 'Purefoil',
                                                                   Location__c = 'EU',
                                                                   Version__c = 3,
                                                                   Valid_From__c = Date.today(),
                                                                   Valid_To__c = Date.today().addDays(5));
        PM_Tubes_Pricing__c testPricing4 = new PM_Tubes_Pricing__c(Ref__c = '1010TG1TestM0568WHITE',
                                                                   X10__c = 15,
                                                                   Tubes_Segments__c = 'Purefoil',
                                                                   Location__c = 'EU',
                                                                   Version__c = 3,
                                                                   Valid_From__c = Date.today(),
                                                                   Valid_To__c = Date.today().addDays(5));
                PM_Tubes_Pricing__c testPricing5 = new PM_Tubes_Pricing__c(Ref__c = '1010TG1standard3-01',
                                                                   X10__c = 15,
                                                                   Tubes_Segments__c = 'Purefoil',
                                                                   Location__c = 'EU',
                                                                   Version__c = 3,
                                                                   Valid_From__c = Date.today(),
                                                                   Valid_To__c = Date.today().addDays(5));
        PM_Tubes_Pricing__c testPricing6 = new PM_Tubes_Pricing__c(Ref__c = '10M0568Peel seal Other printing technology',
                                                                   X10__c = 15,
                                                                   Tubes_Segments__c = 'Purefoil',
                                                                   Location__c = 'EU',
                                                                   Version__c = 3,
                                                                   Valid_From__c = Date.today(),
                                                                   Valid_To__c = Date.today().addDays(5));
        PM_Tubes_Pricing__c testPricing7 = new PM_Tubes_Pricing__c(Ref__c = '',
                                                                   X10__c = 15,
                                                                   Tubes_Segments__c = 'Purefoil',
                                                                   Location__c = 'EU',
                                                                   Version__c = 3,
                                                                   Valid_From__c = Date.today(),
                                                                   Valid_To__c = Date.today().addDays(5));
                PM_Tubes_Pricing__c testPricing8 = new PM_Tubes_Pricing__c(Ref__c = '1010TG1standard13-02',
                                                                   X10__c = 15,
                                                                   Tubes_Segments__c = 'Purefoil',
                                                                   Location__c = 'EU',
                                                                   Version__c = 3,
                                                                   Valid_From__c = Date.today(),
                                                                   Valid_To__c = Date.today().addDays(5));
        		PM_Tubes_Pricing__c testPricing9 = new PM_Tubes_Pricing__c(Ref__c = 'TG1TestM0568Metallizationtest',
                                                                   X10__c = 15,
                                                                   Tubes_Segments__c = 'Purefoil',
                                                                   Location__c = 'EU',
                                                                   Version__c = 3,
                                                                   Valid_From__c = Date.today(),
                                                                   Valid_To__c = Date.today().addDays(5));
        		PM_Tubes_Pricing__c testPricing10 = new PM_Tubes_Pricing__c(Ref__c = 'TG1TestM0568Lacqueringtest',
                                                                   X10__c = 15,
                                                                   Tubes_Segments__c = 'Purefoil',
                                                                   Location__c = 'EU',
                                                                   Version__c = 3,
                                                                   Valid_From__c = Date.today(),
                                                                   Valid_To__c = Date.today().addDays(5));
      
        insert new List<PM_Tubes_Pricing__c> {testPricing,testPricing1,testPricing2,testPricing3,testPricing4,testPricing5,testPricing6,testPricing7,testPricing8,testPricing9,testPricing10};

        //  insert testSelectedConfig;
        PM_Selected_Tubes_Config__c testSelectConfig = new PM_Selected_Tubes_Config__c();
        testSelectConfig.Quote_item__c = qli.id;
        testSelectConfig.Product_segment__c = 'Plastic Tubes';
        testSelectConfig.Purefoil_Segment__c = true;
        testSelectConfig.Location__c = 'EU';
        testSelectConfig.Head_Name__c = 'Test';
        testSelectConfig.Diameter_mm__c = 10;
        testSelectConfig.Delivery__c = 'Delivered';
        testSelectConfig.Printing_Effects__c = 'Test';
        testSelectConfig.Deco_Hot_Stamping__c = 'Test';
        testSelectConfig.Combo_Num_Versions__c = 2;
        testSelectConfig.Metallization__c = 'YES';
	    testSelectConfig.Metallization_Type__c='test';
        testSelectConfig.Lacquering__c = 'YES';
	    testSelectConfig.Lacquering_Type__c='test';
        testSelectConfig.Combo_Num_Tubes_Artwork__c =1;
        testSelectConfig.Combo_Num_Plate_Changes__c = 1;
        testSelectConfig.Nouveau_Platts__c = 1;
        testSelectConfig.Specific_length_mm__c = 10;
        testSelectConfig.Sleeve_length_mm__c = 10;
        testSelectConfig.Head_Aspect__c = 'Head';
        testSelectConfig.Sleeve_Aspect__c = 'Sleeve';
        testSelectConfig.Silk_screen__c = 'Yes';
        testSelectConfig.Printing_type__c ='Print';
        testSelectConfig.PE_Bag__c = 'Yes';
        testSelectConfig.Peel_Seal__c='Yes';
        testSelectConfig.Sleeve_Material_Mix__c = 'PCR';
        testSelectConfig.Payment_terms__c = '60 days';
        testSelectConfig.Cap_Eurocode__c = 'M0568';
        testSelectConfig.Hot_Stamp_Top__c = 'Yes';
        testSelectConfig.Hot_Stamp_Top__c  = 'Yes';
        testSelectConfig.Shrink_band__c  = 'Yes';
        testSelectConfig.Manual_Capping__c  = 'Yes';
        testSelectConfig.Stockage__c ='Yes';
        testSelectConfig.HS_Contouring__c = 'Yes';
        testSelectConfig.Printing_technologies__c = 'Offset';
        insert testSelectConfig;

        PMCalculator_EU_Purefoil pmCalculatorEUPurefoil = new PMCalculator_EU_Purefoil(testSelectConfig);
        pmCalculatorEUPurefoil.calculate();

        Test.stopTest();
    }

}