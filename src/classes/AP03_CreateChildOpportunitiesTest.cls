@isTest
private class AP03_CreateChildOpportunitiesTest {
	@isTest
    public static void AP03_CreateChildOpportunitiesTest(){
	List<User> stUsers = new List<User>();
        stUsers.add(TestFactory.newKamUser(1000));
        stUsers.add(TestFactory.newManagerUser(1001));
        stUsers.add(TestFactory.newAdditionalUser(1002));
        stUsers.add(TestFactory.newDirectorUser(1003));  
        insert stUsers;

        //Create Admin User
        User admUser = TestFactory.newUser('System Administrator', 1);
        insert admUser;

        //Create country
        List<Country__c> countries = TestFactory.newCountry();
        insert countries;
    
        //Create Distribution Channel
        Distribution_Channel__c distCountry1 = TestFactory.newDistributionChannel();
        insert distCountry1;
        
        //Create Sales Area
        Sales_Area__c salesArea = TestFactory.newSalesArea();
        insert salesArea;

        // Create a State
        State__c state = TestFactory.newState('FRANCE','FR');
        insert state;

        //Create one Account
        Account acc1 = TestFactory.newAccount(countries[0].Id,distCountry1.Id,salesArea.Id, state.Id, 'VAT1');
        acc1.Street__c = 'test';
        insert acc1;

        //Create second Account
        Account acc2 = TestFactory.newAccount(countries[0].Id,distCountry1.Id,salesArea.Id, state.Id, 'VAT2');
        acc2.Street__c = 'test';
        insert acc2;

        //Create opportunity
        Opportunity opp1 = TestFactory.newOpportunity('Opp1', 'Qualification', null, null, acc1.Id);
        opp1.Contract__c = 'Yes';
        opp1.Duration_Y__c = '3';

        insert opp1;


        //Create some products for the bulk test
        Set<String> productNames = new set<String>();
        for (Integer i=0; i < 2 + 1; i++) {
            productNames.add('name'+i);
        }
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

        Quote quote1 = TestFactory.newQuote(null, Date.today(), 'Draft', opp1.Id);
        quote1.OwnerId = stUsers[0].Id;
        quote1.Main_compet_1__c = 'OTHER';
        quote1.First_Delivery_Date__c = system.today();
        quote1.Raison_for_lost_on_won_quote__c = 'Quality';
        insert quote1;


        QuoteLineItem qli1 = TestFactory.newQuoteLineItem(quote1.id,products[0].Id,pbEntries[0].Id);
        insert qli1;

        QuoteLineItem qli2 = TestFactory.newQuoteLineItem(quote1.id,products[1].Id,pbEntries[1].Id);
        insert qli2;
        
        

        // synchronize quote and start method

        opp1.SyncedQuoteId = quote1.Id;
        update opp1;

        test.startTest();

        quote1.Status = 'Won';
        update quote1;
       // system.assertEquals([Select id from QuoteLineItem].size(), 6);

        test.stoptest();

        	/*List<Opportunity> input = new List<Opportunity>();
        	input.add(opp1);

            AP03_CreateChildOpportunities.createChildOpportunities(input);*/
        


    }
	
}