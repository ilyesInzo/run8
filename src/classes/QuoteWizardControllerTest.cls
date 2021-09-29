@isTest 
public class QuoteWizardControllerTest {
    public static testmethod void testQuoteWizard(){
    
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
        
        //Account acc2 = new Account(Name = 'Acc 2 de test'+datetime.now(), Country__c = country.Id ,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc2 = TestFactory.newAccount(country, testDistrib, testArea);
        insert acc2;
        
         
        //Create Test Users for the Teams
        List<User> users = new List<User>();
        String pid = [Select id from Profile where Name='System Administrator'].Id; 
        
        //Retrieve KAM PRofile
        Profile KAM = [select id,Name from Profile where Name ='SALES - KAM' limit 1];

        
        for(integer i=1; i<=10; i++){
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
                                    ProfileId = KAM.id,
                                    By_Pass_VR__c =true);
            users.add(tuser);                               
        }
        
        users[4].ProfileId = KAM.id;
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
        
    
       /* Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', 
                                          CloseDate = Date.today());
        insert opp;*/
        
        Product_Sub_segment__c subProd = new Product_Sub_segment__c(
            Name = 'Iron Lotion pumps'
        );
        insert subProd;
        
        
        Product2 prod = new Product2(Name = 'bottle 50ml', 
                                     Family = 'Bottle',
                                     isActive = true, Product_Sub_Segment__c = subProd.Id, ProductCode ='test');
        
        insert prod;
        
        Product2 prod2 = new Product2(Name = 'Tube 50ml', 
                                     Family = 'Tube',
                                     isActive= true, Product_Sub_Segment__c = subProd.Id, ProductCode ='test 2');
        insert prod2;
        
    
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
        
        insert alloc2;
        
        
        List<Sales_allocations__c> allSalesAlloc = new list<sales_allocations__c>();
        allSalesAlloc.add(alloc1);
        allSalesAlloc.add(alloc2);
        
        SalesTeamService.processAllocation(allSalesAlloc, new set<id>());
                
        System.runAs(users[0]){
        
            Opportunity opp1 = new Opportunity(
                Name = 'Test Opp 1', 
                AccountId = acc.Id, 
                StageName = 'Qualification', 
                CloseDate = Date.today()-1
            );
            insert opp1;        
            
            Quote q = new Quote(
                Pricebook2Id = PricebookId, 
                Name = 'Test Quote 1', 
                OpportunityId = opp1.Id, 
                RFQ_Reception_Date__c = Date.today()
            );
            insert q;

            Quote q2 = new Quote( 
                Name = 'Test Quote 2', 
                OpportunityId = opp1.Id, 
                RFQ_Reception_Date__c = Date.today()
            );
            insert q2;
            
            Brand__c brand = new Brand__c(Name = 'OTHER - TO BE ADDED', Validity_to__c = Date.newInstance(4000, 12, 31));
            insert brand;
                
            List<QuoteLineItem> qlis1 = new List<QuoteLineItem>();
            QuoteLineItem qli1 = new QuoteLineItem(
                UnitPrice = 12.0,
                Quantity = 100,
                Sales_price_per_1000_KCur__c = 2,
                Billing_Currency__c = 'American dollar',
                PricebookEntryId= standardPrice.id,
                Product2Id = prod.id, 
                QuoteId = q.Id,
                Production_Cluster__c = 'Albea China',
                Production_Plant__c='Hong Kong PC', Ref_RFQ__c = 'Test',
                Brand__c = brand.Id,
                Product_Brand_Name_to_be_added__c = 'test'
            ); 
            qlis1.add(qli1);  
            
            List<QuoteLineItem> qlis2 = new List<QuoteLineItem>();
            QuoteLineItem qli2 = new QuoteLineItem(
                UnitPrice = 12.0,
                Quantity = 100,
                Sales_price_per_1000_KCur__c = 2,
                PricebookEntryId= standardPrice.id,
                Product2Id = prod2.id, 
                QuoteId = q2.Id,
                Production_Cluster__c = 'Albea China',
                Production_Plant__c='Hong Kong PC', Ref_RFQ__c = 'Test'
            ); 
            qlis2.add(qli2);
            
            
            Map<String, Object> objectMap = QuoteWizardController.getDataOnQuoteWizard(q.Id);
            //The button shuld be displayed for Quote who is not WON, LOST, KILL..
            system.assertEquals(true, objectMap.get('displayAddProductButton'));  
            system.debug('Test Object Map');
            system.debug(objectMap);   
            
            QuoteWizardController.getProductLine(priceBookId);
            
            QuoteWizardController.loadProductLine();
            
            QuoteWizardController.saveQuoteItems(qlis1, q.Id, 'EUR', priceBookId);
            QuoteWizardController.saveQuoteItems(qlis2, q2.Id, 'EUR', priceBookId);
            
            // Change the quote status to Won to test if the Add Product button is not
            // displayed            
            opp1.SyncedQuoteId = q.Id;
            opp1.CloseDate = Date.Today();
            update opp1;

            //update q;
            q = [Select  Pricebook2Id, Name, OpportunityId, RFQ_Reception_Date__c, Status, Main_compet_1__c, Raison_for_lost_on_won_quote__c, First_Delivery_Date__c, Total_Sales_Value_ks__c, IsSyncing from Quote Where id = :q.id];
            
            system.Debug([Select Total_Sales_Value_for_roll_up__c from QuotelineItem]);
            System.debug(LoggingLevel.ERROR,'Total Sales Value Quote = '+q.Total_Sales_Value_ks__c+' IsSyncing = '+q.IsSyncing);
            System.debug(LoggingLevel.ERROR,'Total Sales Value Oppty = '+opp1.Total_Sales_Value_k__c); 

            q.Status = 'Won';
            q.Main_compet_1__c = 'APOLLO';
            q.Raison_for_lost_on_won_quote__c = 'Quality';
            q.First_Delivery_Date__c = Date.today();
            update q;

            System.debug(LoggingLevel.ERROR,'Total Sales Value Quote = '+q.Total_Sales_Value_ks__c+' IsSyncing = '+q.IsSyncing);
            System.debug(LoggingLevel.ERROR,'Total Sales Value Oppty = '+opp1.Total_Sales_Value_k__c);            

            Map<String, Object> objectMap1 = QuoteWizardController.getDataOnQuoteWizard(q.Id);
            system.assertEquals(false, objectMap1.get('displayAddProductButton'));             
            // End test Add Button displayed
             
        }
        
      }

}