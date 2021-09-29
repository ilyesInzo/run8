@isTest
public class customLookUpControllerTest {
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
                                  By_Pass_VR__c = true,
                                  Bypass_Process_Builder__c = 'Sales allocation generation');
            users.add(tuser);                               
        }
        
        users[4].ProfileId = pid;
        users[0].ProfileId = KAM.id;
        insert users;
        
        //Create Test Accounts
        //Account acc = new Account(Name = 'Test Acc 1'+datetime.now(), Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc = new Account();
       // system.runAs(Users[0]){
            acc = TestFactory.newAccount(country, testDistrib, testArea);
            insert acc;
        
        
        //Account acc2 = new Account(Name = 'Acc 2 de test'+datetime.now(), Country__c = country.Id ,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc2 = TestFactory.newAccount(country, testDistrib, testArea);
        insert acc2;
        
        
        
        
        

        
        
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
        
        Opportunity opp = new Opportunity();

            opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', 
                                              CloseDate = Date.today());
            insert opp;       
        
        Opportunity opp2 = new Opportunity();

            opp2 = new Opportunity(Name = 'Test Opp 2', AccountId = acc.Id, StageName = 'Needs Analysis', 
                                              CloseDate = Date.today());
            insert opp2;   

        
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
                                      isActive= true, Product_Sub_Segment__c = subProd.Id, ProductCode ='test2');
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

        Quote q = new Quote(
            Pricebook2Id = PricebookId, 
            Name = 'Test Quote 1', 
            OpportunityId = opp.Id, 
            RFQ_Reception_Date__c = Date.today(),
            Status= 'Draft',
            Main_compet_1__c = 'test',
            Raison_for_lost_on_won_quote__c = 'test',
            First_Delivery_Date__c = system.today()
        );
        insert q;
            
        
        insert TestFactory.newQuoteLineItem(q.Id, prod2.Id, standardPrice.Id);
        opp.SyncedQuoteId = q.Id;
            
        update opp;
        
        q.Status = 'Won';
            
        update q;

        

        
        //Create Team Allocation 1
        Sales_Allocations__c alloc1 = new Sales_Allocations__c();
        alloc1.Account__c = acc.id;
        alloc1.Sales_Team__c = team1.id;
        alloc1.Product__c = 'BTL';
        alloc1.Product_Sub_Segment__c = prod.id;
        alloc1.Valid_From__c = Date.today().addYears(-2);
        alloc1.Valid_To__c = Date.today().addYears(1);
        alloc1.Product_Sub_Segment__c = prod2.Id;

        insert alloc1;
        
        List<Sales_allocations__c> allSalesAlloc = new list<sales_allocations__c>();
        allSalesAlloc.add(alloc1);
        


            List<Account> returnLst = customLookUpController.fetchLookUpValues(acc.Name, 'Account', q.id);
        	
        	
        
            List<Opportunity> returnLst2 = customLookUpController.fetchLookUpValues(opp2.Name, 'Opportunity', q.id);
        
        	
        	List<Account> returnLst1 = customLookUpController.fetchLookUpValues(acc.Name, 'Account', null);
            system.assert(returnLst1.size()>0,returnLst1);
            
           /* system.assertEquals(returnLst.size(), 1);
            system.assertEquals(returnLst[0].Name, acc.Name);
            system.assertEquals(returnLst2.size(), 1);
            system.assertEquals(returnLst2[0].Name, opp2.Name);*/
        	
                      
       // } 
    }
}