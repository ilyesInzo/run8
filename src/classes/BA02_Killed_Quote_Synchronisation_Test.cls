@isTest
private class BA02_Killed_Quote_Synchronisation_Test {
    
    @testSetup
    private static void MyJDD(){
        
        //########################################################"
        
        Country__c frCountry = TestFactory.getFrance();
        
        insert frCountry;  
        
        //Create Distribution Channel
        
        Distribution_Channel__c distCountry1 = TestFactory.newDistributionChannel();
        
        insert distCountry1;              
        
        //Create Sales Area
        
        Sales_Area__c salesArea = TestFactory.newSalesArea();
        
        insert salesArea;
        
        // Create a State
        
        State__c state = TestFactory.newState('FRANCE','FR');
        
        state.Country__c = frCountry.id;
        
        insert state;
        
        //Create Test Accounts
        
        Account acc = TestFactory.newAccount(frCountry.Id,distCountry1.Id,salesArea.Id, state.Id, 'VAT1');
        
        acc.Street__c = 'Cartault';
        
        insert acc;
        
        //Get Standard Pricebook
        
        Opportunity opp = TestFactory.newOpportunity('Opp1', 'Needs Analysis', null, null, acc.Id);
        
        insert opp;  
        
                
    }     
    
    static testmethod void test_BatchCase1() {
        
        Opportunity opp = [select id from Opportunity limit 1];
        Id pricebookId = Test.getStandardPricebookId();
        
        List<Quote> listQuote = new List<Quote>();
        Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 0', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Killed By Albea');
        Quote q1 = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Killed By Albea');
        Quote q2 = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 2', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Killed By Albea');
        listQuote.add(q);
        listQuote.add(q1);
        listQuote.add(q2);
        
        insert listQuote;
        
        test.startTest();
        BA02_Killed_Quote_Synchronisation b = new BA02_Killed_Quote_Synchronisation();
        database.executebatch(b);
        test.stopTest();
        
        Opportunity opp1 = [select id,StageName from Opportunity limit 1];
        System.assert(opp1.StageName == 'Closed Killed', opp1.StageName);
        
    }
    //############################################################"
    
    static testmethod void test_BatchCase2() {
        
        Opportunity opp = [select id from Opportunity limit 1];
        Id pricebookId = Test.getStandardPricebookId();
        
        List<Quote> listQuote = new List<Quote>();
        Quote q3 = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 3', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Draft');
        Quote q4 = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 4', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Draft');
        Quote q5 = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 5', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Killed By Albea');
        listQuote.add(q3);
        listQuote.add(q4);
        listQuote.add(q5);
        
        insert listQuote;
        
        test.startTest();
        BA02_Killed_Quote_Synchronisation b = new BA02_Killed_Quote_Synchronisation();
        database.executebatch(b);
        test.stopTest();
        
        Opportunity opp1 = [select id,StageName from Opportunity limit 1];
        System.assert(opp1.StageName == 'Needs Analysis', opp1.StageName);
        
    }
    
    
    /*

//Créer des Opportunitées 
Opportunity newOpp = new Opportunity(
Name = 'Opp_1',
StageName = 'Needs Analysis',
Quote_Type__c = 'Conversion',
CloseDate = Date.valueOf('31-07-2019'),
Contract__c = 'No',
AccountId = 'newAccount1');

insert newOpp;

//Créer des Quotes
List<Quote> newQuotes = new List<Quote>();
Id priceBookId = Test.getStandardPricebookId();       
Date quoteDueDate1 = Date.newInstance(2019,1,1);
Quote newQuote1 = TestFactory.newQuote('P0', quoteDueDate1, 'Draft', newOpportunities.get(0).Id,
priceBookId);
Date quoteDueDate2 = Date.newInstance(2019,1,1);
Quote newQuote2 = TestFactory.newQuote('P0', quoteDueDate2, 'Draft', newOpportunities.get(1).Id,
priceBookId);
newQuotes.add(newQuote2);       

insert(newQuotes);

}

//Créer des comptes
Account newAccount1 = TestFactory.newAccount
(countries.get(0).Id, 
distributionChannels.get(0).Id,
salesAreas.get(0).Id, 
stateRegions.get(0).Id, 
TestFactory.generateCodeVAT(10));

List<Account> accounts = new List<Account>();
Account newAccount1 = TestFactory.newAccount(countries.get(0).Id, distributionChannels.get(0).Id,

salesAreas.get(0).Id, stateRegions.get(0).Id, TestFactory.generateCodeVAT(10));
accounts.add(newAccount1);    
Account newAccount2 = TestFactory.newAccount(countries.get(1).Id, distributionChannels.get(1).Id,
salesAreas.get(1).Id, stateRegions.get(1).Id, TestFactory.generateCodeVAT(10));
accounts.add(newAccount2);    

insert(accounts);
*/
}