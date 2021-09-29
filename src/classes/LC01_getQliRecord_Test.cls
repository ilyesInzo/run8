@isTest
public class LC01_getQliRecord_Test {
	
        @testSetup
    public static void testSetup(){    
        //We need to get a standard pricebookId
        Id pricebookId = Test.getStandardPricebookId();

        //Create Test Users for the Teams
        List<User> users = new List<User>();    
        for(integer i=1; i<=10; i++){                    
            users.add(TestFactory.newUser('test','user'+i,'SALES - KAM', true, true, true, true, 123+i));                               
        }
        insert users;
        
        System.runAs(users[0]){
            //Create Test Data
            Country__c country = TestFactory.getFrance();
            insert country;
        
            //Create Test Distribution Channel
            Distribution_Channel__c testDistrib = new Distribution_Channel__c(Name ='Test',Distribution_Channel_Code__c='test',Language_Key__c='test');
            insert testDistrib;
            
            //Create Sales Area
            Sales_Area__c testArea = new Sales_Area__c(Name='Test');
            insert testArea;
            
            //Create Test Accounts and allow duplicate
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            //Account acc = new Account(Name = 'Test Acc 1'+datetime.now(), VAT_code__c = 'testcode', Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
            Account acc = TestFactory.newAccount(country, testDistrib, testArea);
            acc.Type = 'Competitor';
            Database.SaveResult sr = Database.insert(acc, dml);
            //Account acc2 = new Account(Name = 'Acc 2 de test'+datetime.now(), VAT_code__c = 'testcode', Country__c = country.Id ,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
            Account acc2 = TestFactory.newAccount(country, testDistrib, testArea);
            acc2.Type = 'Competitor';
            sr = Database.insert(acc2, dml);
            
            //Create Test Sales Teams
            Sales_Team__c team1 = new Sales_Team__c();
            team1.KAM__c = users[0].id;
            team1.Manager__c = users[1].id;
            team1.Director__c = users[2].id;
            team1.Valid_From__c = Date.today().addYears(-1);
            team1.Valid_To__c = Date.today().addYears(3);
            team1.Sales_Team__c = 'test team 1';
            insert team1;
            
            Sales_Team__c team2 = new Sales_Team__c();
            team2.KAM__c = users[4].id;
            team2.Manager__c = users[5].id;
            team2.Director__c = users[6].id;
            team2.Valid_From__c = Date.today().addYears(-1);
            team2.Valid_To__c = Date.today().addYears(3);
            team2.Sales_Team__c = 'test team 2';
            insert team2;
                
            Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
            insert opp;
        
            Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Closed Won');
            insert q;
            
            Product_Sub_segment__c subProd = new Product_Sub_segment__c(
        		Name = 'Iron Lotion pumps'
      		);
      		insert subProd;
            
            Product2 prod = new Product2(Name = 'bottle 50ml', Family = 'Bottle', Product_Sub_Segment__c = subProd.Id);
            insert prod;
            
            Product2 prod2 = new Product2(Name = 'Tube 50ml', Family = 'Tube', Product_Sub_Segment__c = subProd.Id);
            insert prod2;
        
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
            insert standardPrice;
            
            PricebookEntry standardPrice2 = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod2.Id,
                UnitPrice = 5000, IsActive = true);
            insert standardPrice2;
        
            //Create Team Allocation 1
            Sales_Allocations__c alloc1 = new Sales_Allocations__c();
            alloc1.Account__c = acc.id;
            alloc1.Sales_Team__c = team1.id;
            alloc1.Product__c = 'BTL';
            alloc1.Product_Sub_Segment__c = prod.id;
            alloc1.Valid_From__c = Date.today().addYears(-2);
            alloc1.Valid_To__c = Date.today().addYears(1);            
            insert alloc1;
            
            Sales_Allocations__c alloc2 = new Sales_Allocations__c();
            alloc2.Account__c = acc2.id;
            alloc2.Sales_Team__c = team2.id;
            alloc2.Product__c = 'BTL';
            alloc2.Product_Sub_Segment__c = prod2.id;
            alloc2.Valid_From__c = Date.today().addYears(-1);
            alloc2.Valid_To__c = Date.today().addYears(1);            
           // insert alloc2;
            
            //Insert QLI
            QuoteLineItem qli = new QuoteLineItem(UnitPrice = 12.0,Quantity = 100,PricebookEntryId= standardPrice.id,
                                    Production_Cluster__c = 'Albea China',Production_Plant__c ='Hong Kong PC',
                                    Product2Id = prod.id, QuoteId = q.Id, Location__c = 'EU'); 
            insert qli;
        }
    }
    public static testmethod void getQLIRecord(){
        
        QuoteLineItem qli = [select id,QuoteId from QuoteLineItem limit 1];
        
        test.startTest();
        
        QuoteLineItem qliResult = LC01_PriceRecommendation.getQLIRecord(qli.Id);
        QuoteLineItem qliResult1 = LC01_PriceRecommendation.getQLIRecord(qli.QuoteId);
        
        System.assert(qliResult != null);
        System.assert(qliResult1 == null);
        
        test.stopTest();
        
    }
}