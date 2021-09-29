@isTest 
public class Quotes_by_Status_Controller_Test {
    public static testmethod void testQuotesbyStatus(){
    
        //Create Test Data
        Country__c country = new Country__c(Name = 'France', Country_Code__c = 'FX');
        insert country;
    
        //Create Test Distribution Channel
        Distribution_Channel__c testDistrib = new Distribution_Channel__c(Name ='Test',Distribution_Channel_Code__c='test',Language_Key__c='test');
        insert testDistrib;
        
        //Create Sales Area
        Sales_Area__c testArea = new Sales_Area__c(Name='Test');
        insert testArea;
        
        //Create Test Accounts
        //Account acc = new Account(Name = 'Test Acc 1'+datetime.now(), Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        insert acc;
        
        
         
        //Create Test Users for the Teams
        List<User> users = new List<User>();
        String pid = [Select id from Profile where Name='System Administrator'].Id; 
        String marketingId = [Select id from Profile where Name='Marketing'].Id; 
        String funcadmId = [Select id from Profile Where Name = 'Functionnal Administrator' limit 1].Id; 

        //Retrieve KAM PRofile
        Profile KAM = [select id,Name from Profile where Name ='SALES - KAM' limit 1];

        
        for(integer i=1; i<=11; i++){
            String orgId = 'Albea';
                       
            User tuser = new User(  firstname = 'test',
                                    lastName = 'user'+i,
                                    email = 'test_user'+i+ '@test' + orgId + '.com',
                                    Username = 'test_user'+i+ '@test' + orgId + '.com',
                                    EmailEncodingKey = 'ISO-8859-1',
                                    Alias = 'test'+i,
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US',
                                    Additional__c = true,
                                    Director__c = true,
                                    KAM__c = true,
                                    Matricule_ADS__c = string.valueof(i+1000),
                                    Manager__c = true,
                                    ProfileId = KAM.id);
            users.add(tuser);                               
        }
        
        users[4].ProfileId = KAM.id;
        users[0].By_Pass_VR__c = true;
        users[8].ProfileId = marketingId;
        users[9].ProfileId = pid;
        users[10].ProfileId = funcadmId;
        insert users;
        
        
        //Create Test Sales Teams
        Sales_Team__c team1 = new Sales_Team__c();
        team1.KAM__c = users[0].id;
        team1.Manager__c = users[1].id;
        team1.Director__c = users[2].id;
        team1.Additional__c = users[3].id;
        team1.Valid_From__c = Date.today().addYears(-1);
        team1.Valid_To__c = Date.today().addYears(3);
        team1.Sales_Team__c = 'test team 1';
        team1.Sales_Team__c = '1111';
        
        insert team1;
        
        Sales_Team__c team2 = new Sales_Team__c();
        team2.KAM__c = users[4].id;
        team2.Manager__c = users[5].id;
        team2.Director__c = users[6].id;
        team2.Additional__c = users[7].id;
        team2.Valid_From__c = Date.today().addYears(-1);
        team2.Valid_To__c = Date.today().addYears(3);
        team2.Sales_Team__c = 'test team 2';
        team2.Sales_Team__c = '2222';
        insert team2;
        
    
        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', 
                                          CloseDate = Date.today());
        insert opp;
        
        Product_Sub_segment__c subProd = new Product_Sub_segment__c(
            Name = 'Iron Lotion pumps'
        );
        insert subProd;
        
        
        Product2 prod = new Product2(Name = 'bottle 50ml', 
                                     Family = 'Dispensing',
                                     isActive = true, Product_Sub_Segment__c = subProd.Id);
        
        insert prod;
        
        Product2 prod2 = new Product2(Name = 'Tube 50ml', 
                                     Family = 'Tubes',
                                     isActive= true, Product_Sub_Segment__c = subProd.Id);
        insert prod2;
        
        Product2 prod3 = new Product2(Name = 'the CRP', 
                                     Family = 'CRP',
                                     isActive= true, Product_Sub_Segment__c = subProd.Id);
        insert prod3;
        
    
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true, UseStandardPrice=false);
        insert standardPrice;
        //standardPrice.UseStandardPrice
        
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod2.Id,
            UnitPrice = 5000, IsActive = true, UseStandardPrice=false);
        insert standardPrice2;

        PricebookEntry standardPrice3 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod3.Id,
            UnitPrice = 1000, IsActive = true, UseStandardPrice=false);
        insert standardPrice3;
        
        //Create Team Allocation 1
        Sales_Allocations__c alloc1 = new Sales_Allocations__c();
        alloc1.Account__c = acc.id;
        alloc1.Sales_Team__c = team1.id;
        alloc1.Product__c = 'BTL';
        alloc1.Product_Sub_Segment__c = prod.id;
        alloc1.Valid_From__c = Date.today().addYears(-2);
        alloc1.Valid_To__c = Date.today().addYears(1);
        
        insert alloc1;
        
        
        
        List<Sales_allocations__c> allSalesAlloc = new list<sales_allocations__c>();
        allSalesAlloc.add(alloc1);
        
        SalesTeamService.processAllocation(allSalesAlloc, new set<id>());
        

        System.runAs(users[0]){
        
            Opportunity opp1 = new Opportunity(
                Name = 'Test Opp 1', 
                AccountId = acc.Id, 
                StageName = 'Qualification', 
                CloseDate = Date.today()-1
            );
            insert opp1;        
            
            List<Quote> quotes = new List<Quote>();

            Quote q = new Quote(
                Pricebook2Id = PricebookId, 
                Name = 'Test Quote 1', 
                OpportunityId = opp1.Id, 
                RFQ_Reception_Date__c = Date.today()                
            );
            quotes.add(q);
            
            Quote q2 = new Quote( 
                Pricebook2Id = PricebookId,
                Name = 'Test Quote 2', 
                OpportunityId = opp1.Id, 
                RFQ_Reception_Date__c = Date.today(),
                Status = 'Draft',
                Raison_for_lost_on_won_quote__c = 'Quality'
            );
            quotes.add(q2);
            
            Quote q3 = new Quote( 
                Pricebook2Id = PricebookId,
                Name = 'Test Quote 3', 
                OpportunityId = opp1.Id, 
                RFQ_Reception_Date__c = Date.today()                
            );
            quotes.add(q3);
            
            Quote q4 = new Quote( 
                Pricebook2Id = PricebookId,
                Name = 'Test Quote 4', 
                OpportunityId = opp1.Id, 
                RFQ_Reception_Date__c = Date.today()
            );
            quotes.add(q4);
            
            Quote q5 = new Quote( 
                Pricebook2Id = PricebookId,
                Name = 'Test Quote 5', 
                OpportunityId = opp1.Id, 
                RFQ_Reception_Date__c = Date.today()
            );
            quotes.add(q5);

            insert quotes;
            
            List<QuoteLineItem> qlis = new List<QuoteLineItem>();
            
            QuoteLineItem qli1 = new QuoteLineItem(
                UnitPrice = 12.0,
                Quantity = 150,
                Sales_price_per_1000_KCur__c = 2,
                Billing_Currency__c = 'American dollar',
                PricebookEntryId= standardPrice.id,
                Product2Id = prod.id, 
                QuoteId = q.Id,
                Production_Cluster__c = 'Albea China',
                Production_Plant__c='Hong Kong PC', Ref_RFQ__c = 'Test'
            ); 
            qlis.add(qli1);  
            
            QuoteLineItem qli2 = new QuoteLineItem(
                UnitPrice = 12.0,
                Quantity = 100,
                Sales_price_per_1000_KCur__c = 2,
                PricebookEntryId= standardPrice.id,
                Product2Id = prod.id, 
                QuoteId = q.Id,
                Production_Cluster__c = 'Albea China',
                Production_Plant__c='Hong Kong PC', Ref_RFQ__c = 'Test'
            ); 
            qlis.add(qli2);
            
            QuoteLineItem qli3 = new QuoteLineItem(
                UnitPrice = 12.0,
                Quantity = 20,
                Sales_price_per_1000_KCur__c = 2,
                PricebookEntryId= standardPrice.id,
                Product2Id = prod2.id, 
                QuoteId = q.Id,
                Production_Cluster__c = 'Albea China',
                Production_Plant__c='Hong Kong PC', Ref_RFQ__c = 'Test'
            ); 
            qlis.add(qli3);
            
            QuoteLineItem qli4 = new QuoteLineItem(
                UnitPrice = 12.0,
                Quantity = 120,
                Sales_price_per_1000_KCur__c = 2,
                PricebookEntryId= standardPrice.id,
                Product2Id = prod2.id, 
                QuoteId = q3.Id,
                Production_Cluster__c = 'Albea China',
                Production_Plant__c='Hong Kong PC', Ref_RFQ__c = 'Test'
            ); 
            qlis.add(qli4);
            
            QuoteLineItem qli5 = new QuoteLineItem(
                UnitPrice = 12.0,
                Quantity = 200,
                Sales_price_per_1000_KCur__c = 2,
                PricebookEntryId= standardPrice.id,
                Product2Id = prod3.id, 
                QuoteId = q4.Id,
                Production_Cluster__c = 'Albea China',
                Production_Plant__c='Hong Kong PC', Ref_RFQ__c = 'Test'
            ); 
            qlis.add(qli5);
            
            QuoteLineItem qli6 = new QuoteLineItem(
                UnitPrice = 12.0,
                Quantity = 132,
                Sales_price_per_1000_KCur__c = 2,
                PricebookEntryId= standardPrice.id,
                Product2Id = prod3.id, 
                QuoteId = q5.Id,
                Production_Cluster__c = 'Albea China',
                Production_Plant__c='Hong Kong PC', Ref_RFQ__c = 'Test'
            ); 
            qlis.add(qli6);
            
            insert(qlis);

            q.Status = 'Won';
            q.Raison_for_lost_on_won_quote__c = 'Quality';
            q.First_Delivery_Date__c = Date.today();
            q.Main_compet_1__c = 'OTHER';
            update q;

           /* q3.Status = 'Killed By Albea';
            q3.Raison_for_lost_on_won_quote__c = 'Quality';
            q3.Main_compet_1__c = 'OTHER';
            update q3;*/

           /* q4.Status = 'Lost';
            q4.Raison_for_lost_on_won_quote__c = 'Quality';
            q4.First_Delivery_Date__c = Date.today();
            q4.Main_compet_1__c = 'OTHER';
            update q4;*/

         /*   q5.Status = 'Killed By Customer';
            q5.Raison_for_lost_on_won_quote__c = 'Quality';
            q5.Main_compet_1__c = 'OTHER';
            update q5;*/


            test.startTest();

            Boolean isAllowed = Quotes_by_Status_Controller.isAllowed(acc.Id);

            system.assertEquals(isAllowed, true);

            team1.Valid_To__c  = system.today().addDays(-5);
            update team1;

            isAllowed = Quotes_by_Status_Controller.isAllowed(acc.Id);
            system.assertEquals(isAllowed, false);


            String result = Quotes_by_Status_Controller.getData(acc.Id);

         //   system.assertEquals(result, '{"CRP":[0,0,0,0,1,1],"Beauty Solutions":[0,0,0,0,0,0],"Dispensing":[0,0,1,0,0,0],"Tubes":[0,0,1,1,0,0]}'); 

            


        }
        // ALE 05/09 Test Marketing Profile
        system.RunAs(users[8]){
            Boolean isAllowed = Quotes_by_Status_Controller.isAllowed(acc.Id);
            system.assertEquals(isAllowed, true);
        }
        // ALE 14/09 Test Adm profiles
        system.RunAs(users[9]){
            Boolean isAllowed = Quotes_by_Status_Controller.isAllowed(acc.Id);
            system.assertEquals(isAllowed, true);
        }
        system.RunAs(users[10]){
            Boolean isAllowed = Quotes_by_Status_Controller.isAllowed(acc.Id);
            system.assertEquals(isAllowed, true);
        }

        test.stopTest();

      }

}