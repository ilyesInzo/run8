@isTest 
private class VFC02_deepclonequotectrl_TestCase {
    
    @testSetup 
    private static void init() {

        //Create Some Users
        List<User> stUsers = new List<User>();
        stUsers.add(TestFactory.newManagerUser(1001));
        stUsers.add(TestFactory.newAdditionalUser(1002));
        stUsers.add(TestFactory.newDirectorUser(1003));
        stUsers.add(TestFactory.newKamUser(1000));
        User u1 = TestFactory.newKamUser(1234);
        u1.Bypass_trigger__c = 'QLITH.SA_ERRMSG';
        stUsers.add(u1);
        User u2 = TestFactory.newKamUser(4321);
        u2.Bypass_trigger__c = '';
        stUsers.add(u2);
        insert stUsers;

        insert TestFactory.newUser('System Administrator', 1);

        List<Country__c> countries = TestFactory.newCountry();
        insert countries;
        
        Distribution_Channel__c distChannel = TestFactory.newDistributionChannel();
        insert distChannel;
        
        Sales_Area__c salesArea = TestFactory.newSalesArea();
        insert salesArea;

        State__c state = TestFactory.newState('FRANCE','FR');
        insert state;

        //Create some products for the bulk test
        Set<String> productNames = new set<String>();
        for (Integer i=0; i < 2; i++) {
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

        Account acc1 = TestFactory.newAccount(countries[0].Id,distChannel.Id,salesArea.Id, state.Id);
        insert acc1;

        Opportunity opp1 = TestFactory.newOpportunity('Opp1', 'Qualification', null, null, acc1.Id);
        opp1.OwnerId = u1.Id;
        insert opp1;

        Quote quote1 = TestFactory.newQuote(null, Date.today(), 'Draft', opp1.Id);
        quote1.OwnerId = u1.Id;
        insert quote1;

        QuoteLineItem qli1 = TestFactory.newQuoteLineItem(quote1.id,products[0].Id,pbEntries[0].Id);
        insert qli1;
    }

    @isTest
    private static void testDeeploneQuoteCtrl() {
        
        User usr1 = [Select Id From User Where Matricule_ADS__c = '1001'];
        User usr2 = [Select Id From User Where Matricule_ADS__c = '1234'];

        Quote q = [Select Id From Quote Limit 1];
        Opportunity opp = [Select Id From Opportunity Limit 1];
        
        // Test the exception
        System.runAs(usr1) {
            ApexPages.CurrentPage().getParameters().put('Id',q.Id);
            VFC02_deepclonequotectrl deepclone = new VFC02_deepclonequotectrl(new ApexPages.StandardController(q));
            deepclone.deepclonequote();
        }

        // Test the clonage
        System.runAs(usr2) {
            ApexPages.CurrentPage().getParameters().put('Id',q.Id);
            VFC02_deepclonequotectrl deepclone = new VFC02_deepclonequotectrl(new ApexPages.StandardController(q));
            deepclone.deepclonequote();
        }

        
        List<Quote> quotes = [Select Id From Quote Where OpportunityId = :opp.Id];
        List<QuoteLineItem> qlis = [Select Id From QuoteLineItem Where QuoteId != :q.Id];

        //Test if the Quote and QuoteLineItem have been cloned
        System.assertEquals(quotes.size(), 2);
        System.assertEquals(qlis.size(), 1);
        
    }
}