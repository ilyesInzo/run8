@isTest 
public class Test_Batch_Historisation_UpdateCorridors {

    @testSetup 
    public static void testSetup(){

        List<Country__c> countries = new List<Country__c>();
        Country__c france = TestFactory.getFrance();
        countries.add(france);
        Country__c germany = TestFactory.getGermany();
        countries.add(germany);

        insert(countries);


        List<Distribution_Channel__c> distributionChannels = new List<Distribution_Channel__c>();
        Distribution_Channel__c distributionChannel1 = TestFactory.newDistributionChannel('DIRECT SALES', '00001', 'E');
        distributionChannels.add(distributionChannel1);
        Distribution_Channel__c distributionChannel2 = TestFactory.newDistributionChannel('MASS MARKET', '00002', 'E');
        distributionChannels.add(distributionChannel2);

        insert(distributionChannels);


        List<Sales_Area__c> salesAreas = new List<Sales_Area__c>();
        Sales_Area__c salesArea1 = TestFactory.newSalesArea('Interco Global Accounts', 'GA', 'FRC', 'Interco Global Acocunts', 'E', 'FRC', 'G');
        salesAreas.Add(salesArea1);
        Sales_Area__c salesArea2 = TestFactory.newSalesArea('Interco Key Accounts', 'KA', 'FRE', 'Interco Key Accounts', 'E', 'FRE', 'R');
        salesAreas.Add(salesArea2);
        insert(salesAreas);


        List<State__c> stateRegions = new List<State__c>();
        State__c stateRegion1 = TestFactory.newState('Hebei', 'CN-13');
        stateRegions.Add(stateRegion1);
        State__c stateRegion2 = TestFactory.newState('Western Australia', 'AU-WA');
        stateRegions.Add(stateRegion2);
        insert(stateRegions);

 
        
        List<Account> accounts = new List<Account>();
        Account newAccount1 = TestFactory.newAccount(countries.get(0).Id, distributionChannels.get(0).Id,
                salesAreas.get(0).Id, stateRegions.get(0).Id, TestFactory.generateCodeVAT(10));
        accounts.add(newAccount1);    
        Account newAccount2 = TestFactory.newAccount(countries.get(1).Id, distributionChannels.get(1).Id,
                salesAreas.get(1).Id, stateRegions.get(1).Id, TestFactory.generateCodeVAT(10));
        accounts.add(newAccount2);    
        
        insert(accounts);

        
        List<Product_Segment__c> productSegments = new List<Product_Segment__c>();
        Product_Segment__c productSegmentTube = TestFactory.newProductSegment('EN','Laminate Tubes','LAM');
        productSegments.add(productSegmentTube);
        Product_Segment__c productSegmentDisp = TestFactory.newProductSegment('EN','Sampler pumps','SAM');
        productSegments.add(productSegmentDisp);
        Product_Segment__c productSegmentOther = TestFactory.newProductSegment('EN','Pack & Accessories','HARD');
        productSegments.add(productSegmentOther);

        insert(productSegments);


        
        List<Product_Sub_Segment__c> productSubSegments = new List<Product_Sub_Segment__c>();
        Product_Sub_Segment__c productSubSegmentTube = TestFactory.newProductSubSegment('TUB', 'E', 'LAM', productSegmentTube.Id, 'LAM', 'Laminate Tubes', 20.0);
        productSubSegments.Add(productSubSegmentTube);
        Product_Sub_Segment__c productSubSegmentDisp = TestFactory.newProductSubSegment('DIS', 'E', 'SAM', productSegmentDisp.Id, 'SAM', 'Sampler pumps', 10.0);
        productSubSegments.Add(productSubSegmentDisp);
        Product_Sub_Segment__c productSubSegmentOther = TestFactory.newProductSubSegment('BS', 'E', 'HARD', productSegmentOther.Id, 'HARD', 'Accessories', 30.0);
        productSubSegments.Add(productSubSegmentOther);

        insert(productSubSegments);


        List<Product2> products2 = new List<Product2>();
        Product2 productPriceMatrix = TestFactory.newProduct('Tubes', 'Laminated Tubes', 'LAM', productSubSegmentTube.ID, 20.0);
        products2.add(productPriceMatrix);
        Product2 productPriceMatrix2 = TestFactory.newProduct('Dispensing', 'Sampler pumps', 'SAM', productSubSegmentTube.ID, 20.0);
        products2.add(productPriceMatrix2);
        Product2 productLinkforce = TestFactory.newProduct('Beauty Solutions', 'Accessories', 'HARD', productSubSegmentOther.ID, 30.0);
        products2.add(productLinkforce);
        insert(products2);


        List<Opportunity> newOpportunities = new List<Opportunity>();        
        Opportunity newOpportunityPriceMatrix = TestFactory.newOpportunity('newOpportunityPriceMatrix', 'Retention',
            accounts.get(0).Id);
        newOpportunities.add(newOpportunityPriceMatrix);    
        Opportunity newOpportunityLinkforce = TestFactory.newOpportunity('newOpportunityLinkforce', 'Retention',
            accounts.get(1).Id);
        newOpportunities.add(newOpportunityLinkforce);  
        insert(newOpportunities);
        
        
        List<Quote> newQuotes = new List<Quote>();
        Id priceBookId = Test.getStandardPricebookId();       
        Date quoteDueDate1 = Date.newInstance(2019,1,1);
        Quote newQuote1 = TestFactory.newQuote('P0', quoteDueDate1, 'Draft', newOpportunities.get(0).Id,
            priceBookId);
        newQuotes.add(newQuote1);
        Date quoteDueDate2 = Date.newInstance(2019,1,1);
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

        PM_Discount_corridor__c discountCorridor = TestFactory.newPMDiscountCorridor('EU','TestPeerGroup','DOMESTIC ACCOUNT','Selective Market',
            'Personal, Body & Hair Care', 'Laminate Tube', 'TPG', 100, 'TestCriteria1', 'TestCriteria2', 'TestCriteria3', 'TestCriteria4');
        discountCorridor.Valid_From__c = Date.newInstance(2016,01,01); 
        discountCorridor.Valid_To__c = Date.newInstance(2019,02,10);
        discountCorridor.Closed_Price__c = true;
        insert discountCorridor;

        PM_Discount_corridor__c discountCorridor2 = TestFactory.newPMDiscountCorridor('EU','Samplers_Fragrance_GLOBAL ACCOUNT_Mass Market_Sofilux 1,5ml / 2ml','GLOBAL ACCOUNT','Market of Application',
            'Fragrance', 'Samplers', 'PPG', 100, 'Sofilux 1,5ml / 2ml', null, null, null);
        discountCorridor2.Valid_From__c = Date.newInstance(2016,01,01); 
        discountCorridor2.Valid_To__c = Date.newInstance(2019,02,10);
        discountCorridor2.Closed_Price__c = true;
        insert discountCorridor2;


        List<QuoteLineItem> newQuoteLineItems = new List<QuoteLineItem>();   
        QuoteLineItem qliPriceMatrix = TestFactory.newQuoteLineItem(newQuotes.get(0).Id,
            products2.get(0).Id, standardPrices.get(0).Id );
        qliPriceMatrix.selected_corridor__c = discountCorridor.Id;
        newQuoteLineItems.add(qliPriceMatrix);

        QuoteLineItem qliPriceMatrix2 = TestFactory.newQuoteLineItem(newQuotes.get(0).Id,
            products2.get(1).Id, standardPrices.get(0).Id );
        
        newQuoteLineItems.add(qliPriceMatrix2);

        QuoteLineItem qliLinkForce = TestFactory.newQuoteLineItem(newQuotes.get(1).Id,
            products2.get(2).Id, standardPrices.get(1).Id );
        newQuoteLineItems.add(qliLinkForce);

        insert(newQuoteLineItems);



        PM_Selected_Tubes_Config__c newPMSelectedTubesConfig = TestFactory.getPMSelectedTubesConfig(
            'EU', 'Laminate Tubes', 'Cylindrical', 35.0, 100.0, 'M15', 'M15'
        );
        newPMSelectedTubesConfig.Quote_item__c = qliPriceMatrix.id;
        insert(newPMSelectedTubesConfig);

        

        PM_Selected_Dipsensing_Config__c newPMSelectedDispensingConfig = TestFactory.newPMSelectedDispConfig(
            'EU', 'Sampler pumps', qliPriceMatrix2.id
        );
        newPMSelectedDispensingConfig.Quote_item__c = qliPriceMatrix2.id;
        insert(newPMSelectedDispensingConfig);
        qliPriceMatrix2.selected_corridor__c = discountCorridor2.Id;
        update qliPriceMatrix2;
        
       
       


  
    }

    static testmethod void test_Batch() {

            Test.startTest(); 
              Batch_Historisation_UpdateCorridors b = new Batch_Historisation_UpdateCorridors();
		      database.executebatch(b,40);
               
            Test.stopTest();
            list<PM_Discount_corridor__c> existingCorr = [select Id, activity__c, Closed_Price__c 
                                                          from PM_Discount_corridor__c ]; 
            
            for (PM_Discount_corridor__c corr: existingCorr){
               System.assertEquals(corr.Closed_Price__c, false);
            }

            list<QuoteLineItem> qlis = [select Id, Product_Segment__c, selected_corridor__c 
                                        from QuoteLineItem]; 

            for (QuoteLineItem qli:qlis){
              System.assertEquals(qlis[1].selected_corridor__c, null);
            }


    }

}