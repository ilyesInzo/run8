@isTest 
public class Test_Batch_Historisation_UpdatePrices {

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
        Product_Segment__c productSegmentTube = TestFactory.newProductSegment('EN','Plastic Tubes','LAM');
        productSegments.add(productSegmentTube);
        Product_Segment__c productSegmentDisp = TestFactory.newProductSegment('EN','Sampler pumps','SAM');
        productSegments.add(productSegmentDisp);
        Product_Segment__c productSegmentOther = TestFactory.newProductSegment('EN','Pack & Accessories','HARD');
        productSegments.add(productSegmentOther);

        insert(productSegments);


        
        List<Product_Sub_Segment__c> productSubSegments = new List<Product_Sub_Segment__c>();
        Product_Sub_Segment__c productSubSegmentTube = TestFactory.newProductSubSegment('TUB', 'E', 'LAM', productSegmentTube.Id, 'LAM', 'Plastic Tubes', 20.0);
        productSubSegments.Add(productSubSegmentTube);
        Product_Sub_Segment__c productSubSegmentDisp = TestFactory.newProductSubSegment('DIS', 'E', 'SAM', productSegmentDisp.Id, 'LAM', 'Plastic Tubes', 10.0);
        productSubSegments.Add(productSubSegmentDisp);
        Product_Sub_Segment__c productSubSegmentOther = TestFactory.newProductSubSegment('BS', 'E', 'HARD', productSegmentOther.Id, 'HARD', 'Accessories', 30.0);
        productSubSegments.Add(productSubSegmentOther);

        insert(productSubSegments);


        List<Product2> products2 = new List<Product2>();
        Product2 productPriceMatrix = TestFactory.newProduct('Tubes', 'Plastic Tubes', 'LAM', productSubSegmentTube.ID, 20.0);
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

        
        List<QuoteLineItem> newQuoteLineItems = new List<QuoteLineItem>();   
        QuoteLineItem qliPriceMatrix = TestFactory.newQuoteLineItem(newQuotes.get(0).Id,
            products2.get(0).Id, standardPrices.get(0).Id );
        newQuoteLineItems.add(qliPriceMatrix);

        QuoteLineItem qliPriceMatrix2 = TestFactory.newQuoteLineItem(newQuotes.get(0).Id,
            products2.get(1).Id, standardPrices.get(0).Id );
        newQuoteLineItems.add(qliPriceMatrix2);

        QuoteLineItem qliLinkForce = TestFactory.newQuoteLineItem(newQuotes.get(1).Id,
            products2.get(2).Id, standardPrices.get(1).Id );
        newQuoteLineItems.add(qliLinkForce);

        insert(newQuoteLineItems);



        PM_Selected_Tubes_Config__c newPMSelectedTubesConfig = TestFactory.getPMSelectedTubesConfig(
            'EU', 'Plastic Tubes', 'Cylindrical', 35.0, 100.0, 'M15', 'M15'
        );
        newPMSelectedTubesConfig.Quote_item__c = qliPriceMatrix.id;
        newPMSelectedTubesConfig.Sleeve_Material__c = 'Mono';
        newPMSelectedTubesConfig.Sleeve_Material_Mix__c='PCR';
        insert(newPMSelectedTubesConfig);

        list<PM_Tubes_Pricing__c> prices = new list<PM_Tubes_Pricing__c>();
        PM_Tubes_Pricing__c pm = new PM_Tubes_Pricing__c (
         																Ref__c = 'Test Reference', 
         																Location__c  = 'EU',
         																Valid_From__c = Date.newInstance(2016,01,01), 
         																Valid_To__c = Date.newInstance(2019,02,10), 
         																Closed_Price__c = true
         															);
        prices.add(pm);
        PM_Tubes_Pricing__c pm2 = new PM_Tubes_Pricing__c (
         																Ref__c = 'Test New Ref', 
         																Location__c  = 'EU',
         																Valid_From__c = Date.newInstance(2019,02,11), 
         																Valid_To__c = Date.newInstance(2400,01,18)
         															);

        prices.add(pm2);
        insert prices;

        PM_Config_to_Pricing__c junction = new PM_Config_to_Pricing__c(Selected_Tube__c = newPMSelectedTubesConfig.Id,
        															   Tube_Pricing__c = prices[0].Id);
        insert junction;

        PM_Selected_Dipsensing_Config__c newPMSelectedDispensingConfig = TestFactory.newPMSelectedDispConfig(
            'EU', 'Sampler pumps', qliPriceMatrix2.id
        );
        newPMSelectedDispensingConfig.Quote_item__c = qliPriceMatrix2.id;
        insert(newPMSelectedDispensingConfig);

        list<PM_Dispensing_Pricing__c> prices2 = new list<PM_Dispensing_Pricing__c>();
        PM_Dispensing_Pricing__c pm3 = new PM_Dispensing_Pricing__c (
         																Ref__c = 'Test Reference', 
         																Location__c  = 'EU',
         																Valid_From__c = Date.newInstance(2016,01,01), 
         																Valid_To__c = Date.newInstance(2019,02,10), 
         																Closed_Price__c = true
         															);
        prices2.add(pm3);
        PM_Dispensing_Pricing__c pm4 = new PM_Dispensing_Pricing__c (
         																Ref__c = 'Test New Ref', 
         																Location__c  = 'EU',
         																Valid_From__c = Date.newInstance(2019,02,11), 
         																Valid_To__c = Date.newInstance(2400,01,18)
         															);

        prices2.add(pm4);
        insert prices2;

        PM_Config_to_Pricing__c junction2 = new PM_Config_to_Pricing__c(Selected_Dispensing__c = newPMSelectedDispensingConfig.Id,
        															   Dispensing_Pricing__c = prices2[0].Id);
        insert junction2;

    }

    static testmethod void test_Batch() {
          
           
           Test.startTest(); 
              Batch_Historisation_UpdatePrices b = new Batch_Historisation_UpdatePrices();
		      database.executebatch(b,40);
               
           Test.stopTest();
        
           
           list<PM_Config_to_Pricing__c> junctionsList = [select Id,Tube_Pricing__c, Tube_Pricing__r.Closed_Price__c, 
           														 Dispensing_Pricing__c, Dispensing_Pricing__r.Closed_Price__c
           														 from PM_Config_to_Pricing__c];
	       System.assertEquals(junctionsList.size(), 2); 
	     
	       for (PM_Config_to_Pricing__c j:junctionsList){
	           	   if (j.Tube_Pricing__c != null){
	           	   	    System.assertEquals(j.Tube_Pricing__r.Closed_Price__c,false );
	           	   }else if (j.Dispensing_Pricing__c != null){   	    
	                    System.assertEquals(j.Dispensing_Pricing__r.Closed_Price__c,false);
	           	   }
	        }
                    
    }

    static testmethod void test_Schedulable() {
        
        Test.StartTest();
            Batch_Historisation_UpdatePrices_Schdl sh1 = new Batch_Historisation_UpdatePrices_Schdl();
            String sch = '0 0 0 * * ?'; 
            String jobId = system.schedule('Test Batch_Historisation_UpdatePrices_Schdl', sch, sh1);   
        
        Test.stoptest();        
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,  NextFireTime  
                            FROM CronTrigger 
                            WHERE id = :jobId]; 
 
        System.assertNotEquals(ct, null); 
    }

    static testmethod void test_Reprise() {
          
           
           Test.startTest(); 
              Batch_Historisation_RepriseDeDonnees b = new Batch_Historisation_RepriseDeDonnees();
              database.executebatch(b,40);
               
           Test.stopTest();
        
          
                    
    }
}