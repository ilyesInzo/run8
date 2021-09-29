/**
 * [ CopyQuoteTest description : unit test for all the copy quote apex part ]
 *  //
 *  // Attention, there is 8 possible situation that need to be tested
 *  // We're going to generate all the information needed  
 *  //
 *  // Case 1 (testMethodCase1) : Linkforce quote + Cloning and keeping the same opportunity
 *  // Case 2 (testMethodCase2) : linkforce quote + Cloning and linking the cloned quote to another 
 *                                open opportunity with same account as the original opportunity
 *  // Case 3 (testMethodCase3) : linkforce quote + Cloning and linking the cloned quote to a new
 *                                opportunity with same account as the original opportunity
 *  // Case 4 (testMethodCase4) : linkforce quote + Cloning and linking the cloned quote to a new
 *                                opportunity with an existing account different from the original opportunity
 *  // Case 5 (testMethodCase5) : PriceMatrix quote + Cloning and keeping the same opportunity
 *  // Case 6 (testMethodCase6) : PriceMatrix quote + Cloning and linking the cloned quote to another
 *                                open opportunity with same account as the original opportunity
 *  // Case 7 (testMethodCase7) : PriceMatrix quote + Cloning and Linking the cloned quote to a new
 *                                opportunity with the same account as the original opportunity
 *  // Case 8 (testMethodCase8) : PriceMatrix quote + Cloning and linking the cloned quote to a new
 *                                opportunity with an existing account different from the original opportunity
 * ]
 * @author EWA
 * @version 0.5 - Stub
 */
@isTest
public with sharing class CopyQuoteTest {
    //Attributs for the class CopyQuoteTest
    public static String LOG_CLASS_NAME = 'CopyQuoteTest';

    //Methods for the class CopyQuoteTest
    /**
     * [ testSetup description : data initialisation for test purpose]
     */
    @testSetup
    public static void testSetup(){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testSetup Start');     

        //Country Data Initialisation
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Country Initialisation Start');

        List<Country__c> countries = new List<Country__c>();
        Country__c france = TestFactory.getFrance();
        countries.add(france);
        Country__c germany = TestFactory.getGermany();
        countries.add(germany);

        insert(countries);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Country Initialisation Stop');

        //Distribution Channel Data Initialisation
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Distribution Channel Initialisation Start');

        List<Distribution_Channel__c> distributionChannels = new List<Distribution_Channel__c>();
        Distribution_Channel__c distributionChannel1 = TestFactory.newDistributionChannel('DIRECT SALES', '00001', 'E');
        distributionChannels.add(distributionChannel1);
        Distribution_Channel__c distributionChannel2 = TestFactory.newDistributionChannel('MASS MARKET', '00002', 'E');
        distributionChannels.add(distributionChannel2);

        insert(distributionChannels);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Distribution Channel Initialisation Stop');

        //Sales Area Data Initialisation
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Sales Area Initialisation Start');

        List<Sales_Area__c> salesAreas = new List<Sales_Area__c>();
        Sales_Area__c salesArea1 = TestFactory.newSalesArea('Interco Global Accounts', 'GA', 'FRC', 'Interco Global Acocunts', 'E', 'FRC', 'G');
        salesAreas.Add(salesArea1);
        Sales_Area__c salesArea2 = TestFactory.newSalesArea('Interco Key Accounts', 'KA', 'FRE', 'Interco Key Accounts', 'E', 'FRE', 'R');
        salesAreas.Add(salesArea2);
        insert(salesAreas);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Sales Area Initialisation Stop');

        //State Data Initialisation
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - State Initialisation Start');

        List<State__c> stateRegions = new List<State__c>();
        State__c stateRegion1 = TestFactory.newState('Hebei', 'CN-13');
        stateRegions.Add(stateRegion1);
        State__c stateRegion2 = TestFactory.newState('Western Australia', 'AU-WA');
        stateRegions.Add(stateRegion2);
        insert(stateRegions);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - State Initialisation Stop');

        //Account Data Initialisation
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Account Initialisation Start');
        
        List<Account> accounts = new List<Account>();
        Account newAccount1 = TestFactory.newAccount(countries.get(0).Id, distributionChannels.get(0).Id,
                salesAreas.get(0).Id, stateRegions.get(0).Id, TestFactory.generateCodeVAT(10));
        accounts.add(newAccount1);    
        Account newAccount2 = TestFactory.newAccount(countries.get(1).Id, distributionChannels.get(1).Id,
                salesAreas.get(1).Id, stateRegions.get(1).Id, TestFactory.generateCodeVAT(10));
        accounts.add(newAccount2);    
        
        insert(accounts);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Account Initialisation Stop');

        //Product Segement Data initialisation      
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Product Segment initialisation Start');
        
        List<Product_Segment__c> productSegments = new List<Product_Segment__c>();
        Product_Segment__c productSegmentTube = TestFactory.newProductSegment('EN','Laminate Tubes','LAM');
        productSegments.add(productSegmentTube);
        Product_Segment__c productSegmentDisp = TestFactory.newProductSegment('EN','Sampler pumps','SAM');
        productSegments.add(productSegmentDisp);
        Product_Segment__c productSegmentOther = TestFactory.newProductSegment('EN','Pack & Accessories','HARD');
        productSegments.add(productSegmentOther);

        insert(productSegments);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Product Segment Initialisation Stop');

        //Product Sub Segment Data Initialisation
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Product Sub Segment initialisation Start');
        
        List<Product_Sub_Segment__c> productSubSegments = new List<Product_Sub_Segment__c>();
        Product_Sub_Segment__c productSubSegmentTube = TestFactory.newProductSubSegment('TUB', 'E', 'LAM', productSegmentTube.Id, 'LAM', 'Laminate Tubes', 20.0);
        productSubSegments.Add(productSubSegmentTube);
        Product_Sub_Segment__c productSubSegmentDisp = TestFactory.newProductSubSegment('DIS', 'E', 'SAM', productSegmentDisp.Id, 'LAM', 'Laminate Tubes', 10.0);
        productSubSegments.Add(productSubSegmentDisp);
        Product_Sub_Segment__c productSubSegmentOther = TestFactory.newProductSubSegment('BS', 'E', 'HARD', productSegmentOther.Id, 'HARD', 'Accessories', 30.0);
        productSubSegments.Add(productSubSegmentOther);

        insert(productSubSegments);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Product Sub Segment initialisation Stop');

        //Product2 Data Initialisation
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Product Sub Segment (Product2) initialisation Start');

        List<Product2> products2 = new List<Product2>();
        Product2 productPriceMatrix = TestFactory.newProduct('Tubes', 'Laminated Tubes', 'LAM', productSubSegmentTube.ID, 20.0);
        products2.add(productPriceMatrix);
        Product2 productPriceMatrix2 = TestFactory.newProduct('Dispensing', 'Sampler pumps', 'SAM', productSubSegmentTube.ID, 20.0);
        products2.add(productPriceMatrix2);
        Product2 productLinkforce = TestFactory.newProduct('Beauty Solutions', 'Accessories', 'HARD', productSubSegmentOther.ID, 30.0);
        products2.add(productLinkforce);
        insert(products2);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Product Sub Segment (Product2) initialisation Stop');

        //Opportunity Data Initialisation
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Opportunity Initialisation Start');

        List<Opportunity> newOpportunities = new List<Opportunity>();        
        Opportunity newOpportunityPriceMatrix = TestFactory.newOpportunity('newOpportunityPriceMatrix', 'Retention',
            accounts.get(0).Id);
        newOpportunities.add(newOpportunityPriceMatrix);    
        Opportunity newOpportunityLinkforce = TestFactory.newOpportunity('newOpportunityLinkforce', 'Retention',
            accounts.get(1).Id);
        newOpportunities.add(newOpportunityLinkforce);  
        insert(newOpportunities);
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Opportunity Initialisation Start');

        //Quote Data initialisation
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Quote initialisation Start');
        
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
        
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Quote initialisation Stop');

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
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Quote Line Initialisation Start');
        
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

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - Quote Line Initialisation Stop');

        //PM Selected Tubes Config Data Initialisation
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - PM Selected Tubes Config Initialisation Start');

        PM_Selected_Tubes_Config__c newPMSelectedTubesConfig = TestFactory.getPMSelectedTubesConfig(
            'EU', 'Laminate Tubes', 'Cylindrical', 35.0, 100.0, 'M15', 'M15'
        );
        newPMSelectedTubesConfig.Quote_item__c = qliPriceMatrix.id;
        insert(newPMSelectedTubesConfig);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - PM Selected Tubes Config Initialisation Stop');

        //PM Selected Dispensing Config Data Initialisation

        Test.startTest();

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - PM Selected Dispensing Config Initialisation Start');

        PM_Selected_Dipsensing_Config__c newPMSelectedDispensingConfig = TestFactory.newPMSelectedDispConfig(
            'EU', 'Sampler pumps', qliPriceMatrix2.id
        );
        newPMSelectedDispensingConfig.Quote_item__c = qliPriceMatrix2.id;
        insert(newPMSelectedDispensingConfig);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - PM Selected Tubes Config Initialisation Stop');

        Test.stopTest();

        //PM Price Recommendation Data Initialisation
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - PM Price Recommendation Initialisation Start');

        PM_Price_Recommendation__c newPMPriceRecommendation = TestFactory.getPMPriceRecommendation(
            newPMSelectedTubesConfig, qliPriceMatrix, 10, 100, 150, 250, 400, 300
        );
        newPMPriceRecommendation.Discount__c = 10;
        newPMPriceRecommendation.Min_Threshhold_Discount__c = 5;
        newPMPriceRecommendation.Max_Threshhold_Discount__c = 20;
        insert(newPMPriceRecommendation);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - PM Price Recommendation Initialisation Stop');

        //PM Price Detail Data Initialisation
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - PM Price Detail Initialisation Start');

        PM_Price_Detail__c newPMPriceDetail = TestFactory.getPMPriceDetail(
                77, 75, 50, newPMSelectedTubesConfig, 'Basis Price', qliPriceMatrix, 'Tube & Head'
        );
        insert(newPMPriceDetail);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - PM Price Detail Initialisation Stop');

        //PM MOQ Price Data Initialisation
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - PM MOQ Price Initialisation Start');

        PM_MOQ_Price__c newPMMOQPrice = TestFactory.newMoqPrice(
                300.0, 500.0, 'Tubes', newPMSelectedTubesConfig.Id, qliPriceMatrix.Id, 347.08 
        );
        insert(newPMMOQPrice);

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - PM MOQ Price Initialisation Stop.');

        //PM Review NetPrice per MOQ Data Initialisation
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - PM Review NetPrice per MOQ Initialsiation Start');

        PM_Review_NetPrice_per_MOQ__c newPMReviewNetPricePerMOQ = TestFactory.getPMReviewNetPriceperMOQ(
            8.3,
            0.0,
            100,
            newPMPriceDetail,
            newPMPriceRecommendation,
            qliPriceMatrix,
            'Yellow',
            0,
            False
            );
        insert(newPMReviewNetPricePerMOQ);

        Id scoringRT;
        for(RecordType rt : [select Id from RecordType where SobjectType =:'Scoring__c' and DeveloperName = 'Customer']){
            scoringRT = rt.Id;
        }
        Scoring__c score = new Scoring__c(name='testScore', RecordTypeId = scoringRT, location__c = 'EU', Criteria_API_Name__c='Description');
        insert score;

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - PM Review NetPrice per MOQ Initialsiation Stop');

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testSetup Stop');

        //SelectedTubeService
        PM_Selected_Service_Tubes_Config__c newPMSelectedSrvTubesConfig = new PM_Selected_Service_Tubes_Config__c(Quote_item__c = qliPriceMatrix.id, Location__c = 'EU', PM_Selected_Tubes_Config__c = newPMSelectedTubesConfig.id);
        insert(newPMSelectedSrvTubesConfig);

    }

    /**
     * [ testMethodCase1 description : test method for testing the first case ]
     * @test : Linkforce quote + Cloning and keeping the same opportunity
     */
    @isTest
    public static void testMethodCase1(){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testMethodCase1 Start');

        //Will get the quote the linkforce quote
        Opportunity opptyLinkforce = [SELECT Id, Name FROM Opportunity WHERE Name = 'newOpportunityLinkforce']; 
        Quote quote = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE OpportunityID =: opptyLinkforce.Id ];

        //Calling the method that's supposed to be called by the lightning component
        Test.startTest();

        Id cloneQuoteId = CloneQuoteWizard.CloneQuote(quote.Id, '', '', '', '', '', '');
        
        Test.stopTest();

        //Checking if we get a new Quote linked to the same opportunity
        System.assertNotEquals(null, cloneQuoteId, 'The clone return a null Id.');

        //Checking the cloned quote against the orginal
        Quote cloneQuote = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE Id =: cloneQuoteId];

        System.assertNotEquals(quote.Id, cloneQuoteId, 'The clone return the same quote');
        System.assertEquals(quote.AccountId, cloneQuote.AccountId, 'The quote and its cloned doesn\'t have the same account');
        System.assertEquals(quote.OpportunityId, cloneQuote.OpportunityId, 'The quote and its cloned doesn\'t have the same Opportunity');

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testMethodCase1 Stop');
    }

    /**
     * [ testMethodCase2 description : test method for testing the second case ]
     * @test : linkforce quote + Cloning and linking the cloned quote to another 
     *         open opportunity with same account as the original opportunity
     */
    @isTest
    public static void testMethodCase2(){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testMethodCase2 Start');

        //Will get the quote the linkforce quote
        Opportunity opptyLinkforce = [SELECT Id, Name FROM Opportunity WHERE Name = 'newOpportunityLinkforce']; 
        Opportunity anotherOpportunity = [SELECT Id, Name FROM Opportunity WHERE Name = 'newOpportunityPriceMatrix'];
        Quote quote = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE OpportunityID =: opptyLinkforce.Id ];

        //Calling the method that's supposed to be called by the lightning component
        Test.startTest();

        Id cloneQuoteId = CloneQuoteWizard.CloneQuote(quote.Id, '', '', '', '', anotherOpportunity.Id, '');
        
        Test.stopTest();

        //Checking if we get a new Quote linked to the same opportunity
        System.assertNotEquals(null, cloneQuoteId, 'The clone return a null Id.');

        //Checking the cloned quote against the orginal
        Quote cloneQuote = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE Id =: cloneQuoteId];

        System.assertNotEquals(quote.Id, cloneQuoteId, 'The clone return the same quote');
        //System.assertNotEquals(quote.AccountId, cloneQuote.AccountId, 'The quote and its cloned doesn\'t have the same account');
        System.assertNotEquals(quote.OpportunityId, cloneQuote.OpportunityId, 'The quote and its cloned have the same Opportunity');

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testMethodCase2 Stop');
    }

    /**
     * [ testMethodCase3 description : test method for testing the second case ]
     * @test : linkforce quote + Cloning and linking the cloned quote to a new
     *         opportunity with same account as the original opportunity
     */
    @isTest
    public static void testMethodCase3(){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testMethodCase3 Start');

        //Will get the quote the linkforce quote
        Opportunity opptyLinkforce = [SELECT Id, Name FROM Opportunity WHERE Name = 'newOpportunityLinkforce']; 
        Quote quote = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE OpportunityID =: opptyLinkforce.Id ];
        Date today = Date.today();
        Date nextMonth = today.addMonths(-1);

        //Calling the method that's supposed to be called by the lightning component
        Test.startTest();

        Id cloneQuoteId = CloneQuoteWizard.CloneQuote(quote.Id, 'Needs Analysis', 'Penetration', 'Cloned Linkforce Opportunity', String.valueOf(nextMonth), '', '');
        
        Test.stopTest();

        //Checking if we get a new Quote linked to the same opportunity
        System.assertNotEquals(null, cloneQuoteId, 'The clone return a null Id.');

        //Checking the cloned quote against the orginal
        Quote cloneQuote = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE Id =: cloneQuoteId];

        System.assertNotEquals(quote.Id, cloneQuoteId, 'The clone return the same quote');
        System.assertEquals(quote.AccountId, cloneQuote.AccountId, 'The quote and its cloned doesn\'t have the same account');
        System.assertNotEquals(quote.OpportunityId, cloneQuote.OpportunityId, 'The quote and its cloned have the same Opportunity');

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testMethodCase3 Stop');
    }

    /**
     * [ testMethodCase4 description : test method for testing the second case ]
     * @test : linkforce quote + Cloning and linking the cloned quote to a new
     *         opportunity with an existing account different from the original opportunity
     */
    @isTest
    public static void testMethodCase4(){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testMethodCase4 Start');

        //Will get the quote the linkforce quote
        Opportunity opptyLinkforce = [SELECT Id, Name FROM Opportunity WHERE Name = 'newOpportunityLinkforce']; 
        Quote quote = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE OpportunityID =: opptyLinkforce.Id ];
        Account anotherAccount = [ SELECT Id FROM Account LIMIT 1];
        Date today = Date.today();
        Date nextMonth = today.addMonths(-1);

        //Calling the method that's supposed to be called by the lightning component
        Test.startTest();

        Id cloneQuoteId = CloneQuoteWizard.CloneQuote(quote.Id, 'Needs Analysis', 'Penetration', 'Cloned Linkforce Opportunity', String.valueOf(nextMonth), '', anotherAccount.Id);
        
        Test.stopTest();

        //Checking if we get a new Quote linked to the same opportunity
        System.assertNotEquals(null, cloneQuoteId, 'The clone return a null Id.');

        //Checking the cloned quote against the orginal
        Quote cloneQuote = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE Id =: cloneQuoteId];

        System.assertNotEquals(quote.Id, cloneQuoteId, 'The clone return the same quote');
        System.assertNotEquals(quote.AccountId, cloneQuote.AccountId, 'The quote and its cloned have the same account');
        System.assertNotEquals(quote.OpportunityId, cloneQuote.OpportunityId, 'The quote and its cloned have the same Opportunity');

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testMethodCase4 Stop');
    }

    /**
     * [ testMethodCase5 description : test method for testing the second case ]
     * @test : PriceMatrix quote + Cloning and keeping the same opportunity
     */
    @isTest
    public static void testMethodCase5(){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testMethodCase5 Start');

        //Will get the quote the linkforce quote
        Opportunity opptyLinkforce = [SELECT Id, Name FROM Opportunity WHERE Name = 'newOpportunityPriceMatrix']; 
        Quote quote = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE OpportunityID =: opptyLinkforce.Id ];

        //Calling the method that's supposed to be called by the lightning component
        Test.startTest();

        Id cloneQuoteId = CloneQuoteWizard.CloneQuote(quote.Id, '', '', '', '', '', '');
        
        Test.stopTest();

        //Checking if we get a new Quote linked to the same opportunity
        System.assertNotEquals(null, cloneQuoteId, 'The clone return a null Id.');

        //Checking the cloned quote against the orginal
        Quote cloneQuote = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE Id =: cloneQuoteId];

        System.assertNotEquals(quote.Id, cloneQuoteId, 'The clone return the same quote');
        System.assertEquals(quote.AccountId, cloneQuote.AccountId, 'The quote and its cloned doesn\'t have the same account');
        System.assertEquals(quote.OpportunityId, cloneQuote.OpportunityId, 'The quote and its cloned doesn\'t have the same Opportunity');

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testMethodCase5 Stop');
    }

    /**
     * [ testMethodCase6 description : test method for testing the second case ]
     * @test : PriceMatrix quote + Cloning and linking the cloned quote to another
     *         open opportunity with same account as the original opportunity
     */
    @isTest
    public static void testMethodCase6(){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testMethodCase6 Start');

        //Will get the quote the linkforce quote
        Opportunity opptyLinkforce = [SELECT Id, Name FROM Opportunity WHERE Name = 'newOpportunityPriceMatrix']; 
        Opportunity anotherOpportunity = [SELECT Id, Name FROM Opportunity WHERE Name = 'newOpportunityLinkforce'];
        Quote quote = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE OpportunityID =: opptyLinkforce.Id ];

        //Calling the method that's supposed to be called by the lightning component
        Test.startTest();

        Id cloneQuoteId = CloneQuoteWizard.CloneQuote(quote.Id, '', '', '', '', anotherOpportunity.Id, '');
        
        Test.stopTest();

        //Checking if we get a new Quote linked to the same opportunity
        System.assertNotEquals(null, cloneQuoteId, 'The clone return a null Id.');

        //Checking the cloned quote against the orginal
        Quote cloneQuote = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE Id =: cloneQuoteId];

        System.assertNotEquals(quote.Id, cloneQuoteId, 'The clone return the same quote');
        //System.assertEquals(quote.AccountId, cloneQuote.AccountId, 'The quote and its cloned doesn\'t have the same account');
        System.assertNotEquals(quote.OpportunityId, cloneQuote.OpportunityId, 'The quote and its cloned have the same Opportunity');

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testMethodCase6 Stop');
    }

    /**
     * [ testMethodCase7 description : test method for testing the second case ]
     * @test : PriceMatrix quote + Cloning and Linking the cloned quote to a new
     *         opportunity with the same account as the original opportunity
     */
    @isTest
    public static void testMethodCase7(){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testMethodCase7 Start');

        //Will get the quote the linkforce quote
        Opportunity opptyLinkforce = [SELECT Id, Name FROM Opportunity WHERE Name = 'newOpportunityPriceMatrix']; 
        Quote quote = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE OpportunityID =: opptyLinkforce.Id ];
        Date today = Date.today();
        Date nextMonth = today.addMonths(-1);

        //Calling the method that's supposed to be called by the lightning component
        Test.startTest();

        Id cloneQuoteId = CloneQuoteWizard.CloneQuote(quote.Id, 'Needs Analysis', 'Penetration', 'Cloned Linkforce Opportunity', String.valueOf(nextMonth), '', '');
        
        Test.stopTest();

        //Checking if we get a new Quote linked to the same opportunity
        System.assertNotEquals(null, cloneQuoteId, 'The clone return a null Id.');

        //Checking the cloned quote against the orginal
        Quote cloneQuote = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE Id =: cloneQuoteId];

        System.assertNotEquals(quote.Id, cloneQuoteId, 'The clone return the same quote');
        System.assertEquals(quote.AccountId, cloneQuote.AccountId, 'The quote and its cloned doesn\'t have the same account');
        System.assertNotEquals(quote.OpportunityId, cloneQuote.OpportunityId, 'The quote and its cloned have the same Opportunity');

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testMethodCase7 Stop');
    }

    /**
     * [ testMethodCase8 description : test method for testing the second case ]
     * @test : PriceMatrix quote + Cloning and linking the cloned quote to a new
     *         opportunity with an existing account different from the original opportunity
     */
    @isTest
    public static void testMethodCase8(){
        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testMethodCase8 Start');

        //Will get the quote the linkforce quote
        Opportunity opptyLinkforce = [SELECT Id, Name FROM Opportunity WHERE Name = 'newOpportunityPriceMatrix']; 
        Quote quote = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE OpportunityID =: opptyLinkforce.Id ];
        Account anotherAccount = [ SELECT Id FROM Account LIMIT 1 OFFSET 1];
        Date today = Date.today();
        Date nextMonth = today.addMonths(-1);

        //Calling the method that's supposed to be called by the lightning component
        Test.startTest();

        Id cloneQuoteId = CloneQuoteWizard.CloneQuote(quote.Id, 'Needs Analysis', 'Penetration', 'Cloned Linkforce Opportunity', String.valueOf(nextMonth), '', anotherAccount.Id);
        
        Test.stopTest();

        //Checking if we get a new Quote linked to the same opportunity
        System.assertNotEquals(null, cloneQuoteId, 'The clone return a null Id.');

        //Checking the cloned quote against the orginal
        Quote cloneQuote = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE Id =: cloneQuoteId];

        System.assertNotEquals(quote.Id, cloneQuoteId, 'The clone return the same quote');
        System.assertNotEquals(quote.AccountId, cloneQuote.AccountId, 'The quote and its cloned have the same account');
        System.assertNotEquals(quote.OpportunityId, cloneQuote.OpportunityId, 'The quote and its cloned have the same Opportunity');

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testMethodCase4 Stop');

        System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - testMethodCase8 Stop');
    }

    @isTest
    public static void testdisplayButton(){
        Opportunity opptyLinkforce = [SELECT Id, Name FROM Opportunity WHERE Name = 'newOpportunityPriceMatrix']; 
        Quote quote = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE OpportunityID =: opptyLinkforce.Id ];
        Account anotherAccount = [ SELECT Id FROM Account LIMIT 1 OFFSET 1];
        
        Test.startTest();

        system.assertEquals(CloneQuoteWizard.isQuoteWon(quote.id), false);
        system.assertEquals(CloneQuoteWizard.displayCopyQuote(quote.id), false);
        system.assertEquals(CloneQuoteWizard.getNewOpportunity(quote.id), new Opportunity(AccountId = quote.AccountId));

        Test.stopTest();
    }
    
    @isTest
    public static void testOtherMethods(){
        Opportunity oppty = [SELECT Id, Name, StageName, Quote_Type__c, CloseDate, AccountId FROM Opportunity WHERE Name = 'newOpportunityPriceMatrix']; 
        Quote quote = [SELECT Id, AccountId, OpportunityId FROM Quote WHERE OpportunityID =: oppty.Id limit 1];
        QuoteLineItem qli = [SELECT Id FROM QuoteLineItem WHERE Product2.Name = 'Laminated Tubes' ];
        Account anotherAccount = [ SELECT Id FROM Account LIMIT 1 OFFSET 1];

        Test.startTest();

        AP002_QuoteDeepCloneAgent quoteDeepCloneAgent = new AP002_QuoteDeepCloneAgent(quote, 
            true, 
            true,
            oppty.StageName, 
            oppty.Quote_Type__c, 
            oppty.Name, 
            String.valueOf(oppty.CloseDate), 
            String.valueOf(oppty.Id),
            String.valueOf(oppty.AccountId), 
            false, 
            true,
            true
        );
        //AP002_QuoteLineItemDeepCloneAgent tst = new AP002_QuoteLineItemDeepCloneAgent(qli);

        //Test de APXXX_VirtualDeepCloneAgent
        quoteDeepCloneAgent.cantBeCloneAction();
        quoteDeepCloneAgent.updateClonedObject();

        //Test de AP002_QuoteLineItemDeepCloneAgent
        //ASUPquoteDeepCloneAgent.pmReviewNetPriceperMOQs = new List<PM_Review_NetPrice_per_MOQ__c>();
        //ASUPquoteDeepCloneAgent.pmReviewNetPriceperMOQs.add(pmreviewnetpricepermoq);
        AP002_QuoteLineItemDeepCloneAgent qliDeepCloneAgent = quoteDeepCloneAgent.quoteLineItemDeepCloneAgents[0];
        List<PM_Price_Detail__c> test1 = qliDeepCloneAgent.getAllClonedPMPriceDetail();
        List<PM_Selected_Dipsensing_config__c> test2 = qliDeepCloneAgent.getAllClonedPMSelectedDispensingConfig();
        List<PM_MOQ_price__c> test3 = qliDeepCloneAgent.getAllClonedPMMOQPrice();
        List<PM_Selected_Tubes_Config__c> test4 = qliDeepCloneAgent.getAllClonedPMSelectedTubesConfig();
        List<PM_Selected_Service_Tubes_Config__c> test5 = qliDeepCloneAgent.getAllClonedPMSelectedServiceTubesConfig();
        

        Test.stopTest();
    }



}