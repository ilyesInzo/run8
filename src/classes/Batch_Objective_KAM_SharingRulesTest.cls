@isTest
public with sharing class Batch_Objective_KAM_SharingRulesTest {

     @testSetup static void init()
    {
         List<User> users = new List<User>();
        String pid = [Select id from Profile where Name='System Administrator'].Id; 
        
        //Retrieve KAM PRofile
        Profile KAM = [select id,Name from Profile where Name ='SALES - KAM' limit 1];

    
          for(integer i=1; i<=10; i++){
            String orgId = 'Albea';
                       
            User tuser = TestFactory.newUser('test','user'+i, KAM.Name, true, true,true, true, i+1000);
            /*new User(  firstname = 'test',
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
                                    ProfileId = KAM.id);*/
        	tuser.email = 'test_user'+i+ '@test' + orgId + '.com';
            tuser.Username = 'test_user'+i+ '@test' + orgId + '.com';
            tuser.EmailEncodingKey = 'ISO-8859-1';
            tuser.Alias = 'test'+i;
            tuser.TimeZoneSidKey = 'America/Los_Angeles';
            tuser.LocaleSidKey = 'en_US';
            tuser.LanguageLocaleKey = 'en_US';
            users.add(tuser);                               
        }
        
        users[0].ProfileId = KAM.id;
        users[4].ProfileId = KAM.id;
        insert users;
        
         //System.runAs(users[0]){
      
        //Create Test Data
        Country__c country = new Country__c(Name = 'France', Country_Code__c = 'FR');
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
         system.debug('acc id '+acc.id);
        //Account acc2 = new Account(Name = 'Acc 2 de test'+datetime.now(), Country__c = country.Id ,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc2 = TestFactory.newAccount(country, testDistrib, testArea);
        insert acc2; 
          system.debug('acc id '+acc2.id);
        
        //Create Test Sales Teams
        Sales_Team__c team1 = new Sales_Team__c();
        team1.KAM__c = users[0].id;
        team1.Manager__c = users[1].id;
        team1.Director__c = users[2].id;
        //team1.Additional__c = users[3].id;
        team1.Valid_From__c = Date.today().addYears(-1);
        team1.Valid_To__c = Date.today().addYears(3);
        team1.Sales_Team__c = 'test team 1';
        
        insert team1;
        
        Sales_Team__c team2 = new Sales_Team__c();
        team2.KAM__c = users[4].id;
        team2.Manager__c = users[5].id;
        team2.Director__c = users[6].id;
        //team2.Additional__c = users[7].id;
        team2.Valid_From__c = Date.today().addYears(-1);
        team2.Valid_To__c = Date.today().addYears(3);
        team2.Sales_Team__c = 'test team 2';
        insert team2;
     
        //Get Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();
    
        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today());
        insert opp;
    
        Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today());
        insert q;
        
        Product_Sub_segment__c subProd = new Product_Sub_segment__c(
        		Name = 'Iron Lotion pumps'
      		);
      		insert subProd;
        
        Product2 prod = new Product2(Name = 'bottle 50ml', Product_Sub_Segment__c = subProd.Id,
                                     Family = 'Bottle');
        insert prod;
        
        Product2 prod2 = new Product2(Name = 'Tube 50ml', Product_Sub_Segment__c = subProd.Id,
                                     Family = 'Tube');
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
        alloc1.Update_Visibility__c=true;
        
        insert alloc1;
        
        Sales_Allocations__c alloc2 = new Sales_Allocations__c();
        alloc2.Account__c = acc2.id;
        alloc2.Sales_Team__c = team2.id;
        alloc2.Product__c = 'BTL';
        alloc2.Product_Sub_Segment__c = prod2.id;
        alloc2.Valid_From__c = Date.today().addYears(-1);
        alloc2.Valid_To__c = Date.today().addYears(1);
         alloc2.Update_Visibility__c=true;
        //insert alloc2;
        
        
        
        
        //Insert QLI
        QuoteLineItem qli = new QuoteLineItem(
            UnitPrice = 12.0,
            Quantity = 100,
            PricebookEntryId= standardPrice.id,
            Product2Id = prod.id, 
            QuoteId = q.Id,
            Production_Cluster__c='Albea China',
            Production_Plant__c='Hong Kong PC',
        	Ref_RFQ__c = 'Test'
        );  
       
            
        insert qli;

        //Create Plant Record
        Plant_and_Cluster__c testPlant1 = new   Plant_and_Cluster__c();
        testPlant1.Name = 'Hong Kong PC';
        testPlant1.Cluster_Name__c = 'ACH';
        testPlant1.Plant_Code__c = 'HG';
        
        insert testPlant1;
         User admUser = TestFactory.newUser('System Administrator', 1);
        admUser.By_Pass_VR__c = true;
        insert admUser;
   		System.runAs(admUser) {  
        //Create Plant User
        Plant_Segment_Users__c plantUser1 = new Plant_Segment_Users__c();
        plantUser1.Plant_and_Cluster__c = testPlant1.id;
        plantUser1.User__c = users[9].id;
        plantUser1.RecordTypeId = [select Id from RecordType where SObjectType = 'Plant_Segment_Users__c' and DeveloperName ='Plant'].Id;
        
        insert plantUser1;
        
        Plant_Segment_Users__c plantUser2 = new Plant_Segment_Users__c();
        plantUser2.Product__c = prod.id;
        plantUser2.User__c = users[7].id;
        plantUser2.RecordTypeId = [select Id from RecordType where SObjectType = 'Plant_Segment_Users__c' and DeveloperName ='Plant'].Id;
        
  			 }
        
        Objectives__c objective = new Objectives__c(
            Account__c = acc.Id,
            Sales_Allocation__c = alloc1.Id,
            Plant__c = testPlant1.Id,      
            Sub_Segment__c = prod.id 
        );
        objective.Date__c=Date.newInstance(2021, 02, 01);
        insert objective;   
    }
    
    
   static testMethod void Batch_Objective_KAM_SharingRules() 
    {
   
        Test.startTest();

            Batch_Objective_KAM_SharingRules obj = new Batch_Objective_KAM_SharingRules();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
    
    
}