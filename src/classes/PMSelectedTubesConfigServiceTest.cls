@IsTest
public class PMSelectedTubesConfigServiceTest {
    @testSetup
    private static void init() {
        //Create Some Users
        List<User> stUsers = new List<User>();
        stUsers.add(TestFactory.newManagerUser(1001));
        stUsers.add(TestFactory.newAdditionalUser(1002));
        stUsers.add(TestFactory.newDirectorUser(1003));
        stUsers.add(TestFactory.newKamUser(1000));
        User u1 = TestFactory.newKamUser(12341);
        u1.Bypass_trigger__c = 'QLITH.SA_ERRMSG';
        u1.By_Pass_VR__c = true;
        stUsers.add(u1);
        User u2 = TestFactory.newKamUser(43211);
        u2.Bypass_trigger__c = '';
        u1.By_Pass_VR__c = true;
        stUsers.add(u2);
        insert stUsers;

        insert TestFactory.newUser('System Administrator', 1);

        Country__c frCountry = TestFactory.getFrance();
        insert frCountry;

        Distribution_Channel__c distChannel = TestFactory.newDistributionChannel();
        insert distChannel;

        Sales_Area__c salesArea = TestFactory.newSalesArea();
        insert salesArea;

        State__c state = TestFactory.newState('FRANCE', 'FR');
        state.Country__c = frCountry.id;
        insert state;

        //Create some products for the bulk test
        Set<String> productNames = new set<String>();

        productNames.add('Plastic Tubes');
        productNames.add('Laminate Tubes');


        List<Product2> products = TestFactory.newProducts(productNames);
        insert products;

        Id priceBookId = Test.getStandardPricebookId();
        List<PricebookEntry> pbEntries = new List<PricebookEntry>();
        for (Product2 p : products) {
            PricebookEntry standardPrice = new PricebookEntry(
                    Pricebook2Id = priceBookId,
                    Product2Id = p.Id,
                    UnitPrice = 100,
                    IsActive = true);
            pbEntries.add(standardPrice);
        }
        insert pbEntries;

        Account acc1 = TestFactory.newAccount(frCountry.id, distChannel.Id, salesArea.Id, state.Id);
        acc1.Street__c = 'Cartault';
        acc1.Customer_Type__c = 'Brand Owner';
        acc1.Payment_terms__c = '60 days';
        acc1.Business_at_other_product_line__c = 'Yes';
        acc1.Customer_Group__c = 'a0C0Y000001oGdgUAE';
        insert acc1;

        Opportunity opp1 = TestFactory.newOpportunity('Opp1', 'Qualification', null, null, acc1.Id);
        opp1.OwnerId = u1.Id;
        insert opp1;

        Quote quote1 = TestFactory.newQuote(null, Date.today(), 'Draft', opp1.Id);
        quote1.OwnerId = u1.Id;
        insert quote1;

        QuoteLineItem qli1 = TestFactory.newQuoteLineItem(quote1.id, products[0].Id, pbEntries[0].Id);
        insert qli1;
        QuoteLineItem qli2 = TestFactory.newQuoteLineItem(quote1.id, products[0].Id, pbEntries[0].Id);
        insert qli2;

        Sales_Team__c st = TestFactory.newSalesTeam(stUsers[3].Id, stUsers[0].Id, stUsers[1].Id, stUsers[2].Id);
        insert st;

        PM_Selected_Tubes_Config__c pmSelectedConfig = TestFactory.newPMSelectedTubeConfig('EU', 'Laminate', qli1.Id);
        PM_Selected_Tubes_Config__c pmSelectedConfig2 = TestFactory.newPMSelectedTubeConfig('EU', 'Plastic', qli1.Id);
        PM_Selected_Tubes_Config__c pmSelectedConfig3 = TestFactory.newPMSelectedTubeConfig('EU', 'Plastic', qli1.Id);
        pmSelectedConfig3.Purefoil_Segment__c = true;
        pmSelectedConfig.quote_Item__c = qli1.Id;
        pmSelectedConfig2.quote_Item__c = qli1.Id;
        pmSelectedConfig3.quote_Item__c = qli2.Id;
        insert pmSelectedConfig;
        insert pmSelectedConfig2;
        insert pmSelectedConfig3;
        PM_Tubes_Config__c Config = new PM_Tubes_Config__c();
        Config.Resin_Index__c = 2100;
        Config.Tubes_segment__c = 'Laminate';
        Config.Location__c = 'EU';
        Config.Table_Name__c = 'Platts base';
        Config.Active__c = TRUE;
        insert Config;

    }
    @isTest
    static void fillResinIndexValues() {
        List<PM_Selected_Tubes_Config__c> selectTubes = [select Resin_Index__c,Nouveau_Platts__c,Product_segment__c,Location__c,Purefoil_Segment__c from PM_Selected_Tubes_Config__c];
        Test.startTest() ;
        PMSelectedTubesConfigService.fillResinIndexValues(selectTubes);
        Test.stopTest();
        // System.assertEquals();
    }
    @isTest
    static void copyDataToQuoteItem() {
        List<PM_Selected_Tubes_Config__c> selectTubes = [
                select Resin_Index__c,Nouveau_Platts__c,Product_segment__c,Location__c,Purefoil_Segment__c,Diameter_inches__c,
                        Quote_item__c,Diameter_mm__c,Sleeve_Material__c,Sleeve_length_mm__c,Cap_Eurocode__c,Sleeve_type__c,Cap_Name__c,Cap_Color__c,
                        Sleeve_Material_Mix__c,Shape__c,Printing_technologies__c,Sleeve_Aspect__c,Deco_Hot_Stamping__c,Silkscreen__c,Sleeve_Color__c
                        ,Printing_type__c,NB_Flexo_Colors__c,NB_Offset_Colors__c,NB_SS_Colors__c,Printing_Effects__c,HS_Contouring__c,Hot_Stamp_Top__c,
                        Metallization__c,Shrink_band__c,Manual_Capping__c,Dispensing_system_family__c,Head_Name__c,Head_Color__c,Peel_Seal__c
                        ,insert__c,rondelle__c,PE_bag__c,Polysheet__c,Delivery__c,Payment_terms__c,Actuator_Type__c,Silk_screen__c
                        ,Valid_config__c,Cold_Hot_Foil__c,Metalic_Flexo__c,Destination__c,Combo_Num_Tubes_Artwork__c,Sleeve_Length_inches__c,Sleeve_Finish_name__c,Head_Aspect__c,Specific_length_mm__c

                from PM_Selected_Tubes_Config__c
        ];
        Test.startTest() ;
        PMSelectedTubesConfigService.copyDataToQuoteItem(selectTubes);
        Test.stopTest();
        // System.assertEquals();
    }
    @isTest
    static void copyDataToQuoteItem2() {
        List<PM_Selected_Tubes_Config__c> selectTubes = [
                select Resin_Index__c,Nouveau_Platts__c,Product_segment__c,Location__c,Purefoil_Segment__c,Diameter_inches__c,
                        Quote_item__c,Diameter_mm__c,Sleeve_Material__c,Sleeve_length_mm__c,Cap_Eurocode__c,Sleeve_type__c,Cap_Name__c,Cap_Color__c,
                        Sleeve_Material_Mix__c,Shape__c,Printing_technologies__c,Sleeve_Aspect__c,Deco_Hot_Stamping__c,Silkscreen__c,Sleeve_Color__c
                        ,Printing_type__c,NB_Flexo_Colors__c,NB_Offset_Colors__c,NB_SS_Colors__c,Printing_Effects__c,HS_Contouring__c,Hot_Stamp_Top__c,
                        Metallization__c,Shrink_band__c,Manual_Capping__c,Dispensing_system_family__c,Head_Name__c,Head_Color__c,Peel_Seal__c,
                        insert__c,rondelle__c,PE_bag__c,Polysheet__c,Delivery__c,Payment_terms__c,Actuator_Type__c,Silk_screen__c
                        ,Valid_config__c,Cold_Hot_Foil__c,Metalic_Flexo__c,Destination__c,Combo_Num_Tubes_Artwork__c,Sleeve_Length_inches__c,Sleeve_Finish_name__c,Head_Aspect__c,Specific_length_mm__c
                        ,Combo_Num_Versions__c,Number_of_ref_per_run__c,Combo_Num_Plate_Changes__c
                from PM_Selected_Tubes_Config__c
        ];
        Test.startTest() ;
        PMSelectedTubesConfigService.copyDataToQuoteItemVer2(selectTubes);
        Test.stopTest();
        // System.assertEquals();
    }
}