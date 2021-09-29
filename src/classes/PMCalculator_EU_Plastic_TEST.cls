/**
 * <b>Unit Test Class PMCalculator_EU_Plastic_TEST</b>
 * @author EWA
 * @version 1.1.1 - Ensure we are calling the PMCalculator_EU_Plastic class construtor
 * @history 1.1.1 - Ensure we are calling the PMCalculator_EU_Plastic class construtor
 *          1.1   - AssertEquals and pretty printing
 *          1.0   - Initiale Version
 */
@isTest
public class PMCalculator_EU_Plastic_TEST {
    //Methods of the class PMCalculator_EU_Plastic_TEST
    /**
     * [testMethod1 description]
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
        //Account acc = new Account(Name = 'Test Acc 1'+datetime.now(), Country__c = country.Id, Distribution_Channel__c=testDistrib.id,
        //                            Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');

        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        insert acc;

        //Get Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();

        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
        insert opp;

        //Create a quote for the test
        Quote q = new Quote(pricebook2Id = pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(),
                date_Quote_Won__c = Date.today(), Status = 'Draft', Skonto_for_cash_payment__c = '3');
        insert q;

        Product_Sub_segment__c prod2 = new Product_Sub_segment__c(
                Name = 'Iron Lotion pumps'
        );
        insert prod2;

        //Create a product2 record for the test
        Product2 prod = new Product2(Name = 'Plastic Tubes', Family = 'Tubes', IsActive = true, Product_Sub_Segment__c = prod2.Id);
        insert prod;

        //Create a PriceBookEntry record for the test
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        //Insert QLI
        QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0, Quantity = 100, PricebookEntryId = standardPrice.id,
                Product2Id = prod.id, QuoteId = q.Id, ID_Calculette__c = 'PM', Ref_RFQ__c = 'Test');
        qli.Market_Of_Application__c = 'BODY CARE';
        qli.Customer_Type__c = 'Brand Owner';
        qli.Location__c = 'EU';
        qli.Customer_end_of_year_rebate__c = 'Yes (1%)';
        insert qli;

        QuoteLineItem qli2 = new QuoteLineItem(UnitPrice = 12.0, Quantity = 100, PricebookEntryId = standardPrice.id,
                Product2Id = prod.id, QuoteId = q.Id, ID_Calculette__c = 'PM', Ref_RFQ__c = 'Test');
        qli2.Market_Of_Application__c = 'BODY CARE';
        qli2.Customer_Type__c = 'Brand Owner';
        qli2.Location__c = 'EU';
        qli2.Customer_end_of_year_rebate__c = 'Yes (1%)';
        insert qli2;

        //Create Price Details
        List<PM_price_detail__c> priceDetails = new list<PM_price_detail__c>();
        for (integer i = 1; i <= 4; i++) {
            PM_price_detail__c newPriceDetails = new PM_price_detail__c();
            newPriceDetails.Quote_item__c = qli.id;
            newPriceDetails.MOQ_Min__c = 10;
            newPriceDetails.MOQ_Max__c = 20;
            newPriceDetails.List_Price__c = i + 10.50;
            newPriceDetails.Name = 'test' + i;
            priceDetails.add(newPriceDetails);
        }
        insert priceDetails;

        Test.startTest();

        LC01_Review_EU_PlasticController.detailReviewMapClass testMaps = new LC01_Review_EU_PlasticController.detailReviewMapClass();
        testMaps = LC01_Review_EU_PlasticController.getPriceDetails(qli.id, 15);
        testMaps.ReviewPriceMap = LC01_Review_EU_PlasticController.setAllDiscounts(200, 250, testMaps.PriceDetailMap, testMaps.ReviewPriceMap);
        testMaps.ReviewPriceMap = LC01_Review_EU_PlasticController.updatedReviewPriceMap(testMaps.ReviewPriceMap);

        System.assertNotEquals(null, testMaps, 'LC01_Review_EU_PlasticController.getPriceDetails did not send back any data');

        //Insert PM_MOQ_price__c
        PM_MOQ_price__c testMOQPrice = New PM_MOQ_price__c();
        testMOQPrice.Quote_item__c = qli.id;
        testMOQPrice.MOQ_Max__c = 50;
        testMOQPrice.MOQ_Min__c = 25;
        testMOQPrice.List_Price__c = 200.50;
        insert testMOQPrice;

        //Insert productSegmentGlobalConfigs
        PM_Global_Config__c productSegmentGlobalConfigs = new PM_Global_Config__c();
        productSegmentGlobalConfigs.Table_name__c = 'Product Segment';
        productSegmentGlobalConfigs.Product_Segment__c = 'Plastic Tubes';
        productSegmentGlobalConfigs.Location__c = 'EU';
        productSegmentGlobalConfigs.Name_for_discount_corridors__c = 'TEST_CORRIDOR_1';
        insert productSegmentGlobalConfigs;

        //Insert marketAppGlobalConfigs
        PM_Global_Config__c marketAppGlobalConfigs = new PM_Global_Config__c();
        marketAppGlobalConfigs.Table_name__c = 'Market of Application';
        marketAppGlobalConfigs.Location__c = 'EU';
        marketAppGlobalConfigs.Market_of_Application__c = 'BODY CARE';
        marketAppGlobalConfigs.Name_for_discount_corridors__c = 'TEST_CORRIDOR_MARKET';
        insert marketAppGlobalConfigs;

        //Insert macroMarketAppGlobalConfigs
        PM_Global_Config__c macroMarketAppGlobalConfigs = new PM_Global_Config__c();
        macroMarketAppGlobalConfigs.Table_name__c = 'Customer Type';
        macroMarketAppGlobalConfigs.Location__c = 'EU';
        macroMarketAppGlobalConfigs.Customer_Type__c = 'Brand owner';
        macroMarketAppGlobalConfigs.Name_for_discount_corridors__c = '4';
        insert macroMarketAppGlobalConfigs;

        //Inset PM_Tubes_Config__c groupe
        //Inset PM_Tubes_Config__c groupe
        PM_Tubes_Config__c groupe = new PM_Tubes_Config__c();
        groupe.GROUPES_1__c = '10_Test';
        groupe.GROUPES_2__c = 10;
        groupe.Location__c = 'EU';
        insert groupe;

        PM_Tubes_Config__c lengthUpcharge = new PM_Tubes_Config__c();
        lengthUpcharge.Location__c = 'EU';
        lengthUpcharge.Diameter_mm__c = 10;
        lengthUpcharge.Table_name__c = 'Sleeve type codes';
        lengthUpcharge.Sleeve_type__c = 'Coex PCR The Beautiful';
        lengthUpcharge.Active__c = true;
        lengthUpcharge.Tubes_segment__c = 'Plastic';
        lengthUpcharge.STD_LENGTH__c = '10';
        insert lengthUpcharge;


        PM_Tubes_Config__c lengthUpcharge1 = new PM_Tubes_Config__c();
        lengthUpcharge1.Location__c = 'EU';
        lengthUpcharge1.Diameter_mm__c = 10;
        lengthUpcharge1.Table_name__c = 'Platts';
        lengthUpcharge1.Sleeve_type__c = 'Coex PCR The Beautiful';
        lengthUpcharge1.Active__c = true;
        lengthUpcharge1.Printing_Effects__c='Test';
        lengthUpcharge1.Tubes_segment__c = 'Plastic';
        lengthUpcharge1.STD_LENGTH__c = '10';
        lengthUpcharge1.Platts_Poids_Jupe_nets__c=10;
        lengthUpcharge1.Platts_Poids_tete__c=10;
        lengthUpcharge1.Platts_bouchon__c=10;
        insert lengthUpcharge1;

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
        testPricing.Valid_From__c = Date.today();
        testPricing.Valid_To__c = Date.today().addDays(30);
        insert testPricing;

        PM_Tubes_Pricing__c testPricing1 = new PM_Tubes_Pricing__c();
        testPricing1.Version__c = 3;
        testPricing1.Location__c = 'EU';
        testPricing1.Tubes_Segments__c = 'Plastic';
        testPricing1.X10__c = 5;
        testPricing1.X15__c = 5;
        testPricing1.X20__c = 5;
        testPricing1.X25__c = 5;
        testPricing1.X30__c = 5;
        testPricing1.X50__c = 5;
        testPricing1.X75__c = 5;
        testPricing1.X100__c = 5;
        testPricing1.X200__c = 5;
        testPricing1.X250__c = 5;
        testPricing1.X300__c = 5;
        testPricing1.X500__c = 5;
        testPricing1.Ref__c = '1010TG1Test1-01';
        testPricing1.Valid_From__c = Date.today();
        testPricing1.Valid_To__c = Date.today().addDays(30);
        insert testPricing1;

        PM_Tubes_Pricing__c testPricing2 = new PM_Tubes_Pricing__c();
        testPricing2.Version__c = 3;
        testPricing2.Location__c = 'EU';
        testPricing2.Tubes_Segments__c = 'Plastic';
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
        testPricing2.X1000__c = 5;
        testPricing2.Ref__c = '1010TG1standard';
        testPricing2.Valid_From__c = Date.today();
        testPricing2.Valid_To__c = Date.today().addDays(30);
        insert testPricing2;

        PM_Tubes_Pricing__c testPricing3 = new PM_Tubes_Pricing__c();
        testPricing3.Version__c = 3;
        testPricing3.Location__c = 'EU';
        testPricing3.Tubes_Segments__c = 'Plastic';
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
        testPricing3.Ref__c = '1010TG1TestM0568WHITE';
        testPricing3.Valid_From__c = Date.today();
        testPricing3.Valid_To__c = Date.today().addDays(30);
        insert testPricing3;

        PM_Tubes_Pricing__c testPricing4 = new PM_Tubes_Pricing__c();
        testPricing4.Version__c = 3;
        testPricing4.Location__c = 'EU';
        testPricing4.Tubes_Segments__c = 'Plastic';
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
        testPricing4.Ref__c = 'TG1TestM0568Lacqueringtest';
        testPricing4.Valid_From__c = Date.today();
        testPricing4.Valid_To__c = Date.today().addDays(30);
        insert testPricing4;

        PM_Tubes_Pricing__c testPricing5 = new PM_Tubes_Pricing__c();
        testPricing5.Version__c = 3;
        testPricing5.Location__c = 'EU';
        testPricing5.Tubes_Segments__c = 'Plastic';
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
        testPricing5.Ref__c = 'TG1TestM0568Metallizationtest';
        testPricing5.Valid_From__c = Date.today();
        testPricing5.Valid_To__c = Date.today().addDays(30);
        insert testPricing5;

        //  insert testSelectedConfig;
        PM_Selected_Tubes_Config__c testSelectConfig = new PM_Selected_Tubes_Config__c();
        testSelectConfig.Quote_item__c = qli.id;
        testSelectConfig.Product_segment__c = 'Plastic Tubes';
        testSelectConfig.Location__c = 'EU';
        testSelectConfig.Metallization__c = 'YES';
        testSelectConfig.Metallization_Type__c = 'test';
        testSelectConfig.Lacquering__c = 'YES';
        testSelectConfig.Lacquering_Type__c = 'test';
        testSelectConfig.Head_Name__c = 'Test';
        testSelectConfig.Diameter_mm__c = 10;
        testSelectConfig.Delivery__c = 'DAP';
        testSelectConfig.Printing_Effects__c = 'Test';
        testSelectConfig.Deco_Hot_Stamping__c = 'Test';
        testSelectConfig.Combo_Num_Versions__c = 2;
        testSelectConfig.Combo_Num_Tubes_Artwork__c = 1;
        testSelectConfig.Combo_Num_Plate_Changes__c = 1;
        testSelectConfig.Nouveau_Platts__c = 1;
        testSelectConfig.Specific_length_mm__c = 10;
        testSelectConfig.Sleeve_length_mm__c = 10;
        testSelectConfig.Head_Aspect__c = 'Head';
        testSelectConfig.Sleeve_Aspect__c = 'Sleeve';
        testSelectConfig.Silk_screen__c = 'Yes';
        testSelectConfig.Printing_type__c = 'Print';
        testSelectConfig.PE_Bag__c = 'Yes';
        testSelectConfig.Peel_Seal__c = 'Yes';
        //Add Sleeve Material Value
        testSelectConfig.Sleeve_Material__c = 'Coex PCR The Beautiful';
        //end added
        testSelectConfig.Sleeve_Material_Mix__c = 'NON STANDARD MIX';
        testSelectConfig.Printing_technologies__c = 'test';
        testSelectConfig.HS_Contouring__c = 'YES';

        testSelectConfig.Payment_terms__c = '60 days';
        testSelectConfig.Cap_Eurocode__c = 'M0568';
        testSelectConfig.Hot_Stamp_Top__c = 'Yes';
        testSelectConfig.Hot_Stamp_Top__c = 'Yes';
        testSelectConfig.Shrink_band__c = 'Yes';
        testSelectConfig.Manual_Capping__c = 'Yes';
        testSelectConfig.Stockage__c = 'Yes';
        insert testSelectConfig;

        PM_Selected_Tubes_Config__c testSelectConfig2 = new PM_Selected_Tubes_Config__c();
        testSelectConfig2.Quote_item__c = qli2.id;
        testSelectConfig2.Product_segment__c = 'Plastic Tubes';
        testSelectConfig2.Location__c = 'EU';
        testSelectConfig2.Metallization__c = 'YES';
        testSelectConfig2.Metallization_Type__c = 'test';
        testSelectConfig2.Lacquering__c = 'YES';
        testSelectConfig2.Lacquering_Type__c = 'test';
        testSelectConfig2.Head_Name__c = 'Test';
        testSelectConfig2.Diameter_mm__c = 10;
        testSelectConfig2.Delivery__c = 'DAP';
        testSelectConfig2.Printing_Effects__c = 'Test';
        testSelectConfig2.Deco_Hot_Stamping__c = 'Test';
        testSelectConfig2.Combo_Num_Versions__c = 2;
        testSelectConfig2.Combo_Num_Tubes_Artwork__c = 1;
        testSelectConfig2.Combo_Num_Plate_Changes__c = 1;
        testSelectConfig2.Nouveau_Platts__c = 1;
        testSelectConfig2.Specific_length_mm__c = 10;
        testSelectConfig2.Sleeve_length_mm__c = 10;
        testSelectConfig2.Head_Aspect__c = 'Head';
        testSelectConfig2.Sleeve_Aspect__c = 'Sleeve';
        testSelectConfig2.Silk_screen__c = 'Yes';
        testSelectConfig2.Printing_type__c = 'Print';
        testSelectConfig2.PE_Bag__c = 'Yes';
        testSelectConfig2.Peel_Seal__c = 'Yes';
        //Add Sleeve Material Value
        testSelectConfig2.Sleeve_Material__c = 'Coex ISCC CRP';
        //end added
        testSelectConfig2.Sleeve_Material_Mix__c = 'NON STANDARD MIX';
        testSelectConfig2.Printing_technologies__c = 'test';
        testSelectConfig2.HS_Contouring__c = 'YES';

        testSelectConfig2.Payment_terms__c = '60 days';
        testSelectConfig2.Cap_Eurocode__c = 'M0568';
        testSelectConfig2.Hot_Stamp_Top__c = 'Yes';
        testSelectConfig2.Hot_Stamp_Top__c = 'Yes';
        testSelectConfig2.Shrink_band__c = 'Yes';
        testSelectConfig2.Manual_Capping__c = 'Yes';
        testSelectConfig2.Stockage__c = 'Yes';
        insert testSelectConfig2;


        PMCalculator_EU_Plastic pmCalcEUPlastic = new PMCalculator_EU_Plastic(testSelectConfig);
        PMCalculator_EU_Plastic pmCalcEUPlastic2 = new PMCalculator_EU_Plastic(testSelectConfig2);
        pmCalcEUPlastic.calculate();
        pmCalcEUPlastic2.calculate();
        system.assertEquals(PMCalculator_EU_Plastic.getPrintingTG('Offset', 2, 0, 0), 'Offset 1-3');
        system.assertEquals(PMCalculator_EU_Plastic.getPrintingTG('Offset', 5, 0, 0), 'Offset 4-6');
        system.assertEquals(PMCalculator_EU_Plastic.getPrintingTG('Offset', 7, 0, 0), 'Offset 7');
        system.assertEquals(PMCalculator_EU_Plastic.getPrintingTG('Flexo', 0, 4, 0), 'Flexo 1-6');
        system.assertEquals(PMCalculator_EU_Plastic.getPrintingTG('Flexo', 0, 8, 0), 'Flexo 7-10');
        system.assertEquals(PMCalculator_EU_Plastic.getPrintingTG('Silkscreen', 0, 0, 2), 'Silkscreen 1-3');
        system.assertEquals(PMCalculator_EU_Plastic.getPrintingTG('Silkscreen', 0, 0, 5), 'Silkscreen 4-6');
        system.assertEquals(PMCalculator_EU_Plastic.getPrintingTG('Flexo + Silkscreen', 0, 2, 1), 'Flexo 1-4 + Silkscreen 1-2');
        system.assertEquals(PMCalculator_EU_Plastic.getPrintingTG('Flexo + Silkscreen', 0, 2, 3), 'Flexo 1-3 + Silkscreen 3');
        system.assertEquals(PMCalculator_EU_Plastic.getPrintingTG('Offset + Silkscreen', 5, 0, 5), 'Offset 4-6 + Silkscreen 4-6');
        system.assertEquals(PMCalculator_EU_Plastic.getPrintingTG('Offset + Silkscreen', 5, 0, 2), 'Offset 4-6 + Silkscreen 1-3');

        Test.stopTest();


    }


}