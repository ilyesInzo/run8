/**
* @description TEST CLASS for PMReviewNetPriceperMoqService
* @author MQ
* @date 23/11/2017
*/
@isTest
public class PMReviewNetPriceperMoqServiceTest {

    static testmethod void testMethod1() {

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

        //List<Country__c> countries = TestFactory.newCountry();
        //insert countries;
        List<Country__c> countries = new List<Country__c>();
        Country__c france = TestFactory.getFrance();
        countries.add(france);
        Country__c germany = TestFactory.getGermany();
        countries.add(germany);

        insert(countries);

        //Distribution Channel Data Initialisation

        List<Distribution_Channel__c> distributionChannels = new List<Distribution_Channel__c>();
        Distribution_Channel__c distributionChannel1 = TestFactory.newDistributionChannel('DIRECT SALES', '00001', 'E');
        distributionChannels.add(distributionChannel1);
        Distribution_Channel__c distributionChannel2 = TestFactory.newDistributionChannel('MASS MARKET', '00002', 'E');
        distributionChannels.add(distributionChannel2);

        insert(distributionChannels);


        //Sales Area Data Initialisation

        List<Sales_Area__c> salesAreas = new List<Sales_Area__c>();
        Sales_Area__c salesArea1 = TestFactory.newSalesArea('Interco Global Accounts', 'GA', 'FRC', 'Interco Global Acocunts', 'E', 'FRC', 'G');
        salesAreas.Add(salesArea1);
        Sales_Area__c salesArea2 = TestFactory.newSalesArea('Interco Key Accounts', 'KA', 'FRE', 'Interco Key Accounts', 'E', 'FRE', 'R');
        salesAreas.Add(salesArea2);
        insert(salesAreas);

        Sales_Area__c salesArea = TestFactory.newSalesArea();
        insert salesArea;

        State__c state = TestFactory.newState('FRANCE', 'FR');
        state.Country__c = france.id; // Added by Achraf
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

        Account acc1 = TestFactory.newAccount(france.id, distributionChannel1.Id, salesArea.Id, state.Id);
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
        qli2.Total_Score__c = 5;
        qli2.Location__c = 'EU';
        insert qli2;

        Sales_Team__c st = TestFactory.newSalesTeam(stUsers[3].Id, stUsers[0].Id, stUsers[1].Id, stUsers[2].Id);
        insert st;

        //Create some Sales Allocations for the bulk test
        List<Sales_allocations__c> sas = new List<Sales_allocations__c>();
        for (Product2 prod : products) {
            Sales_Allocations__c sa = new Sales_Allocations__c(
                    account__c = acc1.id,
                    product_sub_segment__c = prod.id,
                    sales_team__c = st.id,
                    Valid_To__c = SalesService.FUTURE_DATE
            );
            sas.add(sa);
        }


        //State Data Initialisation


        List<State__c> stateRegions = new List<State__c>();
        State__c stateRegion1 = TestFactory.newState('Hebei', 'CN-13');
        stateRegions.Add(stateRegion1);
        State__c stateRegion2 = TestFactory.newState('Western Australia', 'AU-WA');
        stateRegions.Add(stateRegion2);
        insert(stateRegions);


        //Account Data Initialisation

        List<Account> accounts = new List<Account>();
        Account newAccount1 = TestFactory.newAccount(countries.get(0).Id, distributionChannels.get(0).Id,
                salesAreas.get(0).Id, stateRegions.get(0).Id, TestFactory.generateCodeVAT(10));
        accounts.add(newAccount1);
        Account newAccount2 = TestFactory.newAccount(countries.get(1).Id, distributionChannels.get(1).Id,
                salesAreas.get(1).Id, stateRegions.get(1).Id, TestFactory.generateCodeVAT(10));
        accounts.add(newAccount2);

        insert(accounts);


        //Product Segement Data initialisation


        List<Product_Segment__c> productSegments = new List<Product_Segment__c>();
        Product_Segment__c productSegmentTube = TestFactory.newProductSegment('EN', 'Laminate Tubes', 'LAM');
        productSegments.add(productSegmentTube);
        Product_Segment__c productSegmentDisp = TestFactory.newProductSegment('EN', 'Sampler pumps', 'SAM');
        productSegments.add(productSegmentDisp);
        Product_Segment__c productSegmentOther = TestFactory.newProductSegment('EN', 'Pack & Accessories', 'HARD');
        productSegments.add(productSegmentOther);

        insert(productSegments);


        //Product Sub Segment Data Initialisation

        List<Product_Sub_Segment__c> productSubSegments = new List<Product_Sub_Segment__c>();
        Product_Sub_Segment__c productSubSegmentTube = TestFactory.newProductSubSegment('TUB', 'E', 'LAM', productSegmentTube.Id, 'LAM', 'Laminate Tubes', 20.0);
        productSubSegments.Add(productSubSegmentTube);
        Product_Sub_Segment__c productSubSegmentDisp = TestFactory.newProductSubSegment('DIS', 'E', 'SAM', productSegmentDisp.Id, 'LAM', 'Laminate Tubes', 10.0);
        productSubSegments.Add(productSubSegmentDisp);
        Product_Sub_Segment__c productSubSegmentOther = TestFactory.newProductSubSegment('BS', 'E', 'HARD', productSegmentOther.Id, 'HARD', 'Accessories', 30.0);
        productSubSegments.Add(productSubSegmentOther);

        insert(productSubSegments);


        //Product2 Data Initialisation

        List<Product2> products2 = new List<Product2>();
        Product2 productPriceMatrix = TestFactory.newProduct('Tubes', 'Laminated Tubes', 'LAM', productSubSegmentTube.ID, 20.0);
        products2.add(productPriceMatrix);
        Product2 productPriceMatrix2 = TestFactory.newProduct('Dispensing', 'Sampler pumps', 'SAM', productSubSegmentTube.ID, 20.0);
        products2.add(productPriceMatrix2);
        Product2 productLinkforce = TestFactory.newProduct('Beauty Solutions', 'Accessories', 'HARD', productSubSegmentOther.ID, 30.0);
        products2.add(productLinkforce);
        insert(products2);


        //Opportunity Data Initialisation

        List<Opportunity> newOpportunities = new List<Opportunity>();
        Opportunity newOpportunityPriceMatrix = TestFactory.newOpportunity('newOpportunityPriceMatrix', 'Retention',
                accounts.get(0).Id);
        newOpportunities.add(newOpportunityPriceMatrix);
        Opportunity newOpportunityLinkforce = TestFactory.newOpportunity('newOpportunityLinkforce', 'Retention',
                accounts.get(1).Id);
        newOpportunities.add(newOpportunityLinkforce);
        insert(newOpportunities);


        //Quote Data initialisation

        List<Quote> newQuotes = new List<Quote>();
        //Id priceBookId = Test.getStandardPricebookId();
        Date quoteDueDate1 = Date.newInstance(2019, 1, 1);
        Quote newQuote1 = TestFactory.newQuote('P0', quoteDueDate1, 'Draft', newOpportunities.get(0).Id,
                priceBookId);
        newQuotes.add(newQuote1);
        Date quoteDueDate2 = Date.newInstance(2019, 1, 1);
        Quote newQuote2 = TestFactory.newQuote('P0', quoteDueDate2, 'Draft', newOpportunities.get(1).Id,
                priceBookId);
        newQuotes.add(newQuote2);

        insert(newQuotes);


        //Standard Price
        List<PricebookEntry> standardPrices = new List<PricebookEntry>();

        PricebookEntry standardPrice1 = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = productPriceMatrix.Id,
                UnitPrice = 10000, IsActive = true);
        standardPrices.add(standardPrice1);
        PricebookEntry standardPrice2 = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = productLinkforce.Id,
                UnitPrice = 10000, IsActive = true);
        standardPrices.add(standardPrice2);

        insert standardPrices;

        //Quote Line Data Initialisation
        List<QuoteLineItem> newQuoteLineItems = new List<QuoteLineItem>();
        /* QuoteLineItem qliPriceMatrix = TestFactory.newQuoteLineItem(newQuotes.get(0).Id,
                  products2.get(0).Id, standardPrices.get(0).Id );*/
        QuoteLineItem qliPriceMatrix = new QuoteLineItem();
        qliPriceMatrix.QuoteId = newQuotes.get(0).Id;
        qliPriceMatrix.Product2Id = productPriceMatrix.Id;
        qliPriceMatrix.PricebookEntryId = standardPrices.get(0).Id;
        qliPriceMatrix.Production_Cluster__c = 'Albea China';
        qliPriceMatrix.Location__c = 'EU';
        qliPriceMatrix.Quantity = 30;
        qliPriceMatrix.UnitPrice = 1500;
        qliPriceMatrix.Market_Of_Application__c = 'BODY CARE';

        insert qliPriceMatrix;

        // newQuoteLineItems.add(qliPriceMatrix);
        QuoteLineItem qliPriceMatrix11 = [
                Select ID, QuoteId, Product2Id,PricebookEntryId,Product_Line__c,Production_Cluster__c,Location__c,
                        Quantity,UnitPrice,Market_Of_Application__c

                from QuoteLineItem
                where id = :qliPriceMatrix.id
                limit 1
        ];


        QuoteLineItem qliPriceMatrix2 = TestFactory.newQuoteLineItem(newQuotes.get(0).Id,
                products2.get(1).Id, standardPrices.get(0).Id);
        qliPriceMatrix2.Total_Score__c = 5.0;
        newQuoteLineItems.add(qliPriceMatrix2);

        QuoteLineItem qliLinkForce = TestFactory.newQuoteLineItem(newQuotes.get(1).Id,
                products2.get(2).Id, standardPrices.get(1).Id);
        newQuoteLineItems.add(qliLinkForce);


        insert(newQuoteLineItems);

        //PM Selected Tubes Config Data Initialisation

        PM_Selected_Tubes_Config__c newPMSelectedTubesConfig = TestFactory.getPMSelectedTubesConfig(
                'EU', 'Laminate Tubes', 'Cylindrical', 35.0, 100.0, 'M15', 'M15'
        );//Combo_Num_Plate_Changes__c,Combo_Num_Tubes_Artwork__c,Combo_Num_Versions__c
        newPMSelectedTubesConfig.Quote_item__c = qliPriceMatrix11.id;
        newPMSelectedTubesConfig.Is_Combo__c = 'Yes';
        newPMSelectedTubesConfig.Combo_Num_Versions__c = 2;
        newPMSelectedTubesConfig.Combo_Num_Tubes_Artwork__c = 10000;
        newPMSelectedTubesConfig.Combo_Num_Plate_Changes__c = 6;
        newPMSelectedTubesConfig.Number_of_ref_per_run__c = 6;
        newPMSelectedTubesConfig.Number_of_tubes_per_artwork_in_Ku__c = 10;

        insert(newPMSelectedTubesConfig);
        PM_Selected_Tubes_Config__c newPMSelectedTubesConfig22 = TestFactory.getPMSelectedTubesConfig(
                'EU', 'Laminate Tubes', 'Cylindrical', 35.0, 100.0, 'M15', 'M15'
        );//Combo_Num_Plate_Changes__c,Combo_Num_Tubes_Artwork__c,Combo_Num_Versions__c
        newPMSelectedTubesConfig.Quote_item__c = qli2.id;

        insert(newPMSelectedTubesConfig22);
        PM_Selected_Tubes_Config__c newPMSelectedTubesConfig2 = TestFactory.getPMSelectedTubesConfig(
                'EU', 'Laminate Tubes', 'Cylindrical', 35.0, 100.0, 'M15', 'M15'
        );//,,
        newPMSelectedTubesConfig2.Quote_item__c = qliPriceMatrix11.id;
        newPMSelectedTubesConfig2.Combo_Num_Plate_Changes__c = 4.0;
        newPMSelectedTubesConfig2.Combo_Num_Tubes_Artwork__c = 1000.0;
        newPMSelectedTubesConfig2.Is_Combo__c = 'Yes';
        newPMSelectedTubesConfig2.Combo_Num_Versions__c = 2.0;
        newPMSelectedTubesConfig2.Number_of_ref_per_run__c = 4.0;
        newPMSelectedTubesConfig2.Number_of_tubes_per_artwork_in_Ku__c = 44.0;
        insert(newPMSelectedTubesConfig2);
        PM_Selected_Tubes_Config__c newPMSelectedTubesConfig11 = TestFactory.getPMSelectedTubesConfig(
                'EU', 'Laminate Tubes', 'Cylindrical', 35.0, 100.0, 'M15', 'M15'
        );//,,
        newPMSelectedTubesConfig11.Quote_item__c = qliPriceMatrix11.id;
        newPMSelectedTubesConfig11.Combo_Num_Plate_Changes__c = 4.0;
        newPMSelectedTubesConfig11.Combo_Num_Tubes_Artwork__c = 1000.0;
        newPMSelectedTubesConfig11.Is_Combo__c = 'Yes';
        newPMSelectedTubesConfig11.Combo_Num_Versions__c = 2.0;
        newPMSelectedTubesConfig11.Number_of_ref_per_run__c = 4.0;
        newPMSelectedTubesConfig11.Number_of_tubes_per_artwork_in_Ku__c = 44.0;
        insert(newPMSelectedTubesConfig11);

        //PM Price Recommendation Data Initialisation

        PM_Price_Recommendation__c newPMPriceRecommendation = TestFactory.getPMPriceRecommendation(
                newPMSelectedTubesConfig, qliPriceMatrix11, 99, 100, 150, 250, 400, 300
        );
        newPMPriceRecommendation.Discount__c = 10;
        newPMPriceRecommendation.Min_Threshhold_Discount__c = 5;
        newPMPriceRecommendation.Max_Threshhold_Discount__c = 20;
        insert(newPMPriceRecommendation);
        PM_Price_Recommendation__c newPMPriceRecommendation22 = TestFactory.getPMPriceRecommendation(
                newPMSelectedTubesConfig, qli2, 10, 100, 150, 250, 400, 300
        );
        newPMPriceRecommendation22.Discount__c = 10;
        newPMPriceRecommendation22.Lin1_Price__c = -1;
        newPMPriceRecommendation22.Min_Threshhold_Discount__c = 5;
        newPMPriceRecommendation22.Max_Threshhold_Discount__c = 20;
        insert(newPMPriceRecommendation22);

        //PM Price Detail Data Initialisation

        PM_Price_Detail__c newPMPriceDetail = TestFactory.getPMPriceDetail(
                77, 75, 50, newPMSelectedTubesConfig, 'Freight Price', qliPriceMatrix11, 'Tube & Head'
        );
        insert(newPMPriceDetail);
        PM_Price_Detail__c newPMPriceDetail22 = TestFactory.getPMPriceDetail(
                -1, 75, 50, newPMSelectedTubesConfig, 'Basis Price', qli2, 'Tube & Head'
        );
        insert(newPMPriceDetail22);
        PM_Price_Detail__c newPMPriceDetail1 = TestFactory.getPMPriceDetail(
                70, 65, 40, newPMSelectedTubesConfig2, 'Combo', qliPriceMatrix11, 'Others'
        );
        insert(newPMPriceDetail1);
        PM_Price_Detail__c newPMPriceDetail31 = TestFactory.getPMPriceDetail(
                70, 65, 40, newPMSelectedTubesConfig, 'Combo', qliPriceMatrix11, 'Others'
        );
        insert(newPMPriceDetail31);
        //PM MOQ Price Data Initialisation

        PM_MOQ_Price__c newPMMOQPrice = TestFactory.newMoqPrice(
                300.0, 999, 'Tubes', newPMSelectedTubesConfig.Id, qliPriceMatrix11.Id, 347.08
        );
        insert(newPMMOQPrice);
        PM_MOQ_Price__c newPMMOQPrice11 = TestFactory.newMoqPrice(
                300.0, 999, 'Tubes', newPMSelectedTubesConfig11.Id, qliPriceMatrix11.Id, 347.08
        );
        insert(newPMMOQPrice11);
        PM_MOQ_Price__c newPMMOQPrice22 = TestFactory.newMoqPrice(
                300.0, 500.0, 'Tubes', newPMSelectedTubesConfig22.Id, qli2.Id, 347.08
        );
        insert(newPMMOQPrice22);


        //PM Review NetPrice per MOQ Data Initialisation


        PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ = TestFactory.getPMReviewNetPriceperMOQ(
                8.3,
                0.0,
                100,
                newPMPriceDetail,
                newPMPriceRecommendation,
                qliPriceMatrix11,
                'Yellow',
                0,

                true
        );
        newPMReviewNetPricePerMOQ.Quoted_Price__c = 10;

        insert(newPMReviewNetPricePerMOQ);

        PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ11 = [
                SELECT Id,Delta_vs_List_Price__c,
                        MOQ_Units__c,PM_Price_Detail__c,PriceReco__c,Quote_Line_Item__c,Quote_Line_Item__r.Product_Line__c,
                        Quoted_Price__c,Reviewed_price__c,Selected__c,Transport_Price__c,Quote_Line_Item__r.Location__c,EXW_Price__c

                from PM_Review_NetPrice_per_MOQ__c
                where id = :newPMReviewNetPricePerMOQ.id
        ];

        PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ22 = TestFactory.getPMReviewNetPriceperMOQ(
                8.3,
                0.0,
                null,
                newPMPriceDetail22,
                newPMPriceRecommendation22,
                qli2,
                'Yellow',
                0,
                False
        );

        insert newPMReviewNetPricePerMOQ22;

        PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ222 = [
                SELECT Id,Delta_vs_List_Price__c,
                        MOQ_Units__c,PM_Price_Detail__c,PriceReco__c,Quote_Line_Item__c,Quote_Line_Item__r.Product_Line__c,
                        Quoted_Price__c,Reviewed_price__c,Selected__c,Transport_Price__c,Quote_Line_Item__r.Location__c,EXW_Price__c

                from PM_Review_NetPrice_per_MOQ__c
                where id = :newPMReviewNetPricePerMOQ22.id
        ];

        PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ33 = TestFactory.getPMReviewNetPriceperMOQ(
                8.3,
                0.0,
                100,
                newPMPriceDetail,
                newPMPriceRecommendation,
                qliPriceMatrix11,
                'Yellow',
                0,

                true
        );
        newPMReviewNetPricePerMOQ33.Quoted_Price__c = 0;
        newPMReviewNetPricePerMOQ33.EXW_Price__c = 10;

        insert(newPMReviewNetPricePerMOQ33);

        PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ333 = [
                SELECT Id,Delta_vs_List_Price__c,
                        MOQ_Units__c,PM_Price_Detail__c,PriceReco__c,Quote_Line_Item__c,Quote_Line_Item__r.Product_Line__c,
                        Quoted_Price__c,Reviewed_price__c,Selected__c,Transport_Price__c,Quote_Line_Item__r.Location__c,EXW_Price__c

                from PM_Review_NetPrice_per_MOQ__c
                where id = :newPMReviewNetPricePerMOQ33.id
        ];


        PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ44 = TestFactory.getPMReviewNetPriceperMOQ(
                8.3,
                0.0,
                100,
                newPMPriceDetail,
                newPMPriceRecommendation,
                qliPriceMatrix11,
                'Yellow',
                0,

                true
        );
        newPMReviewNetPricePerMOQ44.Quoted_Price__c = 0;
        newPMReviewNetPricePerMOQ44.EXW_Price__c = 10;

        insert(newPMReviewNetPricePerMOQ44);

        PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ444 = [
                SELECT Id,Delta_vs_List_Price__c,
                        MOQ_Units__c,PM_Price_Detail__c,PriceReco__c,Quote_Line_Item__c,Quote_Line_Item__r.Product_Line__c,
                        Quoted_Price__c,Reviewed_price__c,Selected__c,Transport_Price__c,Quote_Line_Item__r.Location__c,EXW_Price__c

                from PM_Review_NetPrice_per_MOQ__c
                where id = :newPMReviewNetPricePerMOQ44.id
        ];

        PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ55 = TestFactory.getPMReviewNetPriceperMOQ(
                8.3,
                0.0,
                100,
                newPMPriceDetail,
                newPMPriceRecommendation,
                qliPriceMatrix11,
                'Yellow',
                0,

                true
        );
        newPMReviewNetPricePerMOQ55.Quoted_Price__c = 0;
        newPMReviewNetPricePerMOQ55.EXW_Price__c = 10;

        insert(newPMReviewNetPricePerMOQ55);

        PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ555 = [
                SELECT Id,Delta_vs_List_Price__c,
                        MOQ_Units__c,PM_Price_Detail__c,PriceReco__c,Quote_Line_Item__c,Quote_Line_Item__r.Product_Line__c,
                        Quoted_Price__c,Reviewed_price__c,Selected__c,Transport_Price__c,Quote_Line_Item__r.Location__c,EXW_Price__c

                from PM_Review_NetPrice_per_MOQ__c
                where id = :newPMReviewNetPricePerMOQ44.id
        ];
        PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ66 = TestFactory.getPMReviewNetPriceperMOQ(
                8.3,
                0.0,
                100,
                newPMPriceDetail,
                newPMPriceRecommendation,
                qliPriceMatrix11,
                'Yellow',
                0,

                true
        );
        newPMReviewNetPricePerMOQ66.Quoted_Price__c = 0;
        newPMReviewNetPricePerMOQ66.EXW_Price__c = 10;

        insert(newPMReviewNetPricePerMOQ66);

        PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ666 = [
                SELECT Id,Delta_vs_List_Price__c,
                        MOQ_Units__c,PM_Price_Detail__c,PriceReco__c,Quote_Line_Item__c,Quote_Line_Item__r.Product_Line__c,
                        Quoted_Price__c,Reviewed_price__c,Selected__c,Transport_Price__c,Quote_Line_Item__r.Location__c,EXW_Price__c

                from PM_Review_NetPrice_per_MOQ__c
                where id = :newPMReviewNetPricePerMOQ66.id
        ];

        PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ77 = TestFactory.getPMReviewNetPriceperMOQ(
                8.3,
                0.0,
                100,
                newPMPriceDetail,
                newPMPriceRecommendation,
                qliPriceMatrix11,
                'Yellow',
                0,

                true
        );
        newPMReviewNetPricePerMOQ77.Quoted_Price__c = 0;
        newPMReviewNetPricePerMOQ77.EXW_Price__c = 10;

        insert(newPMReviewNetPricePerMOQ77);

        PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ777 = [
                SELECT Id,Delta_vs_List_Price__c,
                        MOQ_Units__c,PM_Price_Detail__c,PriceReco__c,Quote_Line_Item__c,Quote_Line_Item__r.Product_Line__c,
                        Quoted_Price__c,Reviewed_price__c,Selected__c,Transport_Price__c,Quote_Line_Item__r.Location__c,EXW_Price__c

                from PM_Review_NetPrice_per_MOQ__c
                where id = :newPMReviewNetPricePerMOQ77.id
        ];

        PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ88 = TestFactory.getPMReviewNetPriceperMOQ(
                8.3,
                0.0,
                100,
                newPMPriceDetail,
                newPMPriceRecommendation,
                qliPriceMatrix11,
                'Yellow',
                0,

                true
        );
        newPMReviewNetPricePerMOQ88.Quoted_Price__c = 0;
        newPMReviewNetPricePerMOQ88.EXW_Price__c = 10;

        insert(newPMReviewNetPricePerMOQ88);

        PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ888 = [
                SELECT Id,Delta_vs_List_Price__c,
                        MOQ_Units__c,PM_Price_Detail__c,PriceReco__c,Quote_Line_Item__c,Quote_Line_Item__r.Product_Line__c,
                        Quoted_Price__c,Reviewed_price__c,Selected__c,Transport_Price__c,Quote_Line_Item__r.Location__c,EXW_Price__c

                from PM_Review_NetPrice_per_MOQ__c
                where id = :newPMReviewNetPricePerMOQ88.id
        ];




        list<PM_Review_NetPrice_per_MOQ__c> newprices = new List<PM_Review_NetPrice_per_MOQ__c>();
       newprices.add(newPMReviewNetPricePerMOQ11);
        newprices.add(newPMReviewNetPricePerMOQ222);
        newprices.add(newPMReviewNetPricePerMOQ333);
        newprices.add(newPMReviewNetPricePerMOQ444);
        newprices.add(newPMReviewNetPricePerMOQ555);
        newprices.add(newPMReviewNetPricePerMOQ666);
        Id scoringRT;
        for (RecordType rt : [select Id from RecordType where SobjectType = :'Scoring__c' and DeveloperName = 'Customer']) {
            scoringRT = rt.Id;
        }
        Scoring__c score = new Scoring__c(name = 'testScore', RecordTypeId = scoringRT, location__c = 'EU', Criteria_API_Name__c = 'Description');
        insert score;


        //SelectedTubeService
        PM_Selected_Service_Tubes_Config__c newPMSelectedSrvTubesConfig = new PM_Selected_Service_Tubes_Config__c(Quote_item__c = qliPriceMatrix11.id, Location__c = 'EU', PM_Selected_Tubes_Config__c = newPMSelectedTubesConfig.id);
        insert(newPMSelectedSrvTubesConfig);
        //LC01_PriceRecommendation.getSelectedPriceCorridor('', 'PET CARE','ICN2' ,'Brand owner');
        PM_Selected_Service_Tubes_Config__c newPMSelectedSrvTubesConfig22 = new PM_Selected_Service_Tubes_Config__c(Quote_item__c = qli2.id, Location__c = 'EU', PM_Selected_Tubes_Config__c = newPMSelectedTubesConfig22.id);
        insert(newPMSelectedSrvTubesConfig22);
        Test.startTest();
        PMReviewNetPriceperMoqService.calculatePriceColor(newprices);
        PMReviewNetPriceperMoqService.updateRelatedQuotelineitem_BULK(newprices);
        test.stopTest();


    }

}