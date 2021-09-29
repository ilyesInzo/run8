@isTest
public class AP01_Objective_Rules_TEST {
  /*
  * Test the objectiveReAffectation methode => the objective is linked to a valid allocation
  *@@qama commented : for depl in prod => not already tested in preprod*/
  @TestSetup
    static void Init()
    {
       
    }
    static testmethod void testobjectiveReAffectationPositive(){
    //Creer des compte
        Country__c country = new Country__c(Name = 'France', Country_Code__c = 'FR');
        insert country;
    
        //Create Test Distribution Channel
        Distribution_Channel__c testDistrib = new Distribution_Channel__c(Name ='Test',Distribution_Channel_Code__c='test',Language_Key__c='test');
        insert testDistrib;
        
        //Create Sales Area
        Sales_Area__c testArea = new Sales_Area__c(Name='Test');
        insert testArea;
        
        //Create Test Accounts
        //Account acc = new Account(Name = 'Test Acc i test'+datetime.now(), Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        insert acc;
        
        Product_Sub_segment__c prod2 = new Product_Sub_segment__c(
            Name = 'Iron Lotion pumps'
        );
        insert prod2;
        
    //creer des produits
      Product2 prod = new Product2(Name = 'Plastic Tubes', isActive=true,
                                     Family = 'Tubes', Product_Sub_Segment__c = prod2.Id);
        insert prod;
        
    //creer des plant and cluster
    Plant_and_Cluster__c plantAndCluster = new Plant_and_Cluster__c(Cluster_code__c='VA' ,Cluster_Name__c= 'Tubes Europe', Plant_Code__c='TUE'  );
    insert plantAndCluster;
    
    //creer des sales teams
    User testUser = [select id from user where  KAM__c= true and manager__c = true and profile.name='SALES - KAM' AND Matricule_ADS__c != null limit 1];
    Sales_Team__c salesTeam = new Sales_Team__c(Name= 'Test Sales Team test', kam__c=testUser.id);
    insert salesTeam;
    
    Sales_Team__c salesTeamArchive = new Sales_Team__c(valid_to__c = date.today()-1, Name= 'Test Sales Team xx', kam__c=testUser.id, manager__c = testUser.id);
    insert salesTeamArchive;
    
    //creer des sales alloc
    Sales_Allocations__c salesAlloc = new Sales_Allocations__c(Account__c = acc.id, Product_Sub_Segment__c=prod.id);
    insert salesAlloc;
    
    Sales_Allocations__c salesAllocArchive = new Sales_Allocations__c(valid_to__c = date.today()-1, Account__c = acc.id, Product_Sub_Segment__c=prod.id);
    insert salesAllocArchive;
    
    //creer des objectifs
    Objectives__c obj = new Objectives__c(Account__c=  acc.id, Sub_Segment__c = prod.id,Sales_Allocation__c=salesAlloc.id,Plant__c=plantAndCluster.id  );
    insert obj;
    
    /**Objectives__c invalidObj = new Objectives__c(Account__c=  acc.id, Sub_Segment__c = prod.id,Sales_Allocation__c=salesAllocArchive.id,Plant__c=plantAndCluster.id  );
    insert invalidObj;
    
    //check before modif
    system.AssertNotEquals([select id from Objectives__c where alloc_valid_to_date__c < TODAY OR alloc_valid_to_date__c = null].size() ,0);
    */
    Test.starttest();
      Database.executeBatch(new BA00_ReAffect_Objective_Rules()); 
    Test.stopTest();
    
    //check after modif
    system.AssertEquals([select id from Objectives__c where alloc_valid_to_date__c < TODAY OR alloc_valid_to_date__c = null].size() ,0);
  
  }//end test testobjectiveReAffectationPositive
  
  
  
    static testmethod void testobjectiveReAffectation(){
            
        
        //Create Test Users for the Teams
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
        users[0].By_Pass_VR__c = true;
        users[4].ProfileId = KAM.id;
        insert users;
        
       // System.runAs(users[0]){
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
            
            //Account acc2 = new Account(Name = 'Acc 2 de test'+datetime.now(), Country__c = country.Id ,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
            Account acc2 = TestFactory.newAccount(country, testDistrib, testArea);
            insert acc2;
            
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
        
            Quote q = new Quote(pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(), date_Quote_Won__c=Date.today(),  Status='Closed Won');
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
            
            insert alloc1;
            
            Sales_Allocations__c alloc2 = new Sales_Allocations__c();
            alloc2.Account__c = acc2.id;
            alloc2.Sales_Team__c = team2.id;
            alloc2.Product__c = 'BTL';
            alloc2.Product_Sub_Segment__c = prod2.id;
            alloc2.Valid_From__c = Date.today().addYears(-1);
            alloc2.Update_Objective_Sharing__c = true;
            alloc2.Valid_To__c = Date.today().addYears(1);
            
          //  insert alloc2;
            
            
            
            //Insert QLI
            QuoteLineItem qli = new QuoteLineItem(
                UnitPrice = 12.0,
                Quantity = 100,
                PricebookEntryId= standardPrice.id,
                Production_Cluster__c = 'Albea China',
                Production_Plant__c ='Hong Kong PC',
                Product2Id = prod.id, QuoteId = q.Id,
             Ref_RFQ__c = 'Test'
            );
               
            insert qli;
            
            Objectives__c obj = new Objectives__c(Name='test', Sub_Segment__c =prod.id , Account__c = acc.Id, Date__c=Date.today());
          obj.Year_Objective__c=1200;
            insert obj;
            
            List<Quote> qlist = new List<Quote>();
            qlist.add(q);
            AP01_Objective_Rules.ObjectiveNetNewBusiness(new List<Objectives__c>{obj});
            AP01_Objective_Rules.ObjectiveLostRetention(new List<Objectives__c>{obj});
      
            Objectives__c objectif = [
                Select  Monthly_Achievment__c,
                        Date__c,
                        Sub_Segment__c,
                        Account__c,
                        Plant__r.Plant_Code__c,
                        Plant__r.Name
                From Objectives__c
                Limit 1
            ];

            QuoteLineItem qliInserted = [
                Select Total_Sales_value_k__c
                From QuoteLineItem
                Where Id = :qli.Id
            ];

            System.assertEquals(qliInserted.Total_Sales_value_k__c, objectif.Monthly_Achievment__c);
        
           
            Test.startTest(); 
            //List< Objectives__c > Objs = [Select Id, Date__c,alloc_valid_to_date__c, Account__c, Sub_Segment__c FROM Objectives__c];
            AP01_Objective_Rules.objectiveReAffectation(new List<Objectives__c>{obj});
                Database.executeBatch(new BA01_Objective_Rules());
                
                BA01_Objective_Rules batch1 = new BA01_Objective_Rules();
                batch1.query = 'Select Id, Date__c, Account__c, Sub_Segment__c FROM Objectives__c';
                Database.executeBatch(batch1);
                
                    
                SCH_scheduledBatchable sch_Batch_Calc = new SCH_scheduledBatchable();
                String schedule = '0 0 23 * * ?';
                system.schedule('Batch Calc', schedule, sch_Batch_Calc);        
            
                System.runAs(users[0]){
                opp.Quote_Type__c = 'Retention';
                update opp;
                q.Status='Closed Lost';
                update q;
                Database.executeBatch(batch1);
                
                BA01_Objective_Rules_LostRetention batch2 = new BA01_Objective_Rules_LostRetention();
                batch2.query='';
                Database.executeBatch(batch2);
                
                }
                  
            Test.stopTest();

            objectif = [
                Select  Monthly_Achievment__c,
                        Lost_Retention__c                    
                From Objectives__c
                Limit 1
            ];

            qliInserted = [
                Select Total_Sales_value_k__c
                From QuoteLineItem
                Where Id = :qli.Id
            ];

            System.assertEquals(qliInserted.Total_Sales_value_k__c, objectif.Monthly_Achievment__c);
            System.assertEquals(qliInserted.Total_Sales_value_k__c, objectif.Lost_Retention__c);
        
      //  }
        
      }
      
      
      static testmethod void testobjectivesharing(){
    
        //Create Test Users for the Teams
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
        
        //Account acc2 = new Account(Name = 'Acc 2 de test'+datetime.now(), Country__c = country.Id ,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc2 = TestFactory.newAccount(country, testDistrib, testArea);
        insert acc2;       
        
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
        
        insert alloc1;
        
        Sales_Allocations__c alloc2 = new Sales_Allocations__c();
        alloc2.Account__c = acc2.id;
        alloc2.Sales_Team__c = team2.id;
        alloc2.Product__c = 'BTL';
        alloc2.Product_Sub_Segment__c = prod2.id;
        alloc2.Valid_From__c = Date.today().addYears(-1);
        alloc2.Valid_To__c = Date.today().addYears(1);
        
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
         
       user adminisr= [select id from user where id=:userInfo.getUserId()];
        //Create Plant User
          system.runAs(adminisr){
        Plant_Segment_Users__c plantUser1 = new Plant_Segment_Users__c();
        plantUser1.Plant_and_Cluster__c = testPlant1.id;
        plantUser1.User__c = users[9].id;
        plantUser1.RecordTypeId = [select Id from RecordType where SObjectType = 'Plant_Segment_Users__c' and DeveloperName ='Plant'].Id;
        
        insert plantUser1;
        
        Plant_Segment_Users__c plantUser2 = new Plant_Segment_Users__c();
        plantUser2.Product__c = prod.id;
        plantUser2.User__c = users[7].id;
        plantUser2.RecordTypeId = [select Id from RecordType where SObjectType = 'Plant_Segment_Users__c' and DeveloperName ='Plant'].Id;
        
        insert plantUser2;       
          }
        Objectives__c objective = new Objectives__c(
            Account__c = acc.Id,
            Sales_Allocation__c = alloc1.Id,
            Plant__c = testPlant1.Id,
            Sub_Segment__c = prod.id 
        );
        insert objective;        
          
        AP01_Objective_Rules.kamObjectiveshare([Select Id, Account__c, Sub_Segment__c, Sales_Allocation__r.Account__c, Sales_Allocation__r.Product_Sub_Segment__c, Sales_Allocation__r.Valid_To__c, Sales_Allocation__r.Valid_From__c, Sales_Allocation__c,
        Sales_Allocation__r.Sales_Team__r.KAM__c, Sales_Allocation__r.Sales_Team__r.Manager__c, Sales_Allocation__r.Sales_Team__r.Director__c, Sales_Allocation__r.Sales_Team__r.Additional__c From Objectives__c 
        WHERE Sales_Allocation__r.Product_Sub_Segment__c != null and Sales_Allocation__r.Account__c != null]);
        
        
        AP01_Objective_Rules.PlantObjectiveshare([Select Id, Plant__c From Objectives__c where Plant__c != null and CreatedDate >=:date.today()]);
        
        Test.startTest();        
            Database.executeBatch(new BA01_Objective_KAM_SharingRules());
            Database.executeBatch(new Batch_Objective_KAM_SharingRules());
            Database.executeBatch(new BA01_Objective_Plant_SharingRules());
            
                
            SCH_scheduledBatchable sch_Batch_Calc = new SCH_scheduledBatchable();
            String cron = '0 0 23 * * ?';
            System.schedule('Batch Calc', cron, sch_Batch_Calc);

            SCH_DailyObjectiveCalculation schedule1 = new SCH_DailyObjectiveCalculation();
            System.schedule('Test DailyObjectiveCalculation Scheduler', cron, schedule1);

            SCH_DailyObjectiveSharingRules schedule2 = new SCH_DailyObjectiveSharingRules();
            System.schedule('Test DailyObjectiveSharingRules Scheduler', cron, schedule2);

        
        Test.stopTest();
        
       // }

        List<Objectives__Share> objectiveShares = [
            Select UserOrGroupId
            From Objectives__Share
        ];

        Objectives__c objectif = [
            Select 
                Sales_Allocation__r.Sales_Team__r.KAM__c,
                Sales_Allocation__r.Sales_Team__r.Director__c,
                Sales_Allocation__r.Sales_Team__r.Manager__c,
                Sales_Allocation__r.Sales_Team__r.Additional__c
            From Objectives__c
            Limit 1
        ]; 

        Set<Id> stIds = new set<Id> {
            objectif.Sales_Allocation__r.Sales_Team__r.KAM__c,
            objectif.Sales_Allocation__r.Sales_Team__r.Director__c,
            objectif.Sales_Allocation__r.Sales_Team__r.Manager__c,
            objectif.Sales_Allocation__r.Sales_Team__r.Additional__c
        };

        Integer nbrSTWhoShare = [
            Select count()
            From Objectives__Share
            Where UserOrGroupId In :stIds
        ];
        
        // Expected 3 because there is no additional in the test teams
        System.assertEquals(3,nbrSTWhoShare);
        

      }
     
   static testmethod void testSubSegmentObjectivesharing(){
    
        //Create Test Users for the Teams
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
        
        // System.runAs(users[0]){
        
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
        
        //Account acc2 = new Account(Name = 'Acc 2 de test'+datetime.now(), Country__c = country.Id ,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc2 = TestFactory.newAccount(country, testDistrib, testArea);
        insert acc2;       
        
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
        
        insert plantUser2;       
        
        Plant_Segment_Users__c plantUser3 = new Plant_Segment_Users__c();
        plantUser3.Product__c = prod.id;
        plantUser3.User__c = users[3].id;
        plantUser3.RecordTypeId = [select Id from RecordType where SObjectType = 'Plant_Segment_Users__c' and DeveloperName ='Plant'].Id;
        
        insert plantUser3;       
        
        Objectives__c objective = new Objectives__c(
            Account__c = acc.Id,
            Sales_Allocation__c = alloc1.Id,
            Plant__c = testPlant1.Id,
            Sub_Segment__c = prod.id 
        );
        insert objective;
        
        
        Test.startTest();  
          AP01_Objective_Rules.SubSegmentObjectiveshare([Select Id, Sub_Segment__c From Objectives__c where Sub_Segment__c != null and CreatedDate >=:date.today()]);
            Database.executeBatch(new BA01_Objective_Plant_SharingRules());            
                
            SCH_scheduledBatchable sch_Batch_Calc = new SCH_scheduledBatchable();
            String cron = '0 0 23 * * ?';
            System.schedule('Batch Calc', cron, sch_Batch_Calc);

            SCH_DailyObjectiveCalculation schedule1 = new SCH_DailyObjectiveCalculation();
            System.schedule('Test DailyObjectiveCalculation Scheduler', cron, schedule1);

            SCH_DailyObjectiveSharingRules schedule2 = new SCH_DailyObjectiveSharingRules();
            System.schedule('Test DailyObjectiveSharingRules Scheduler', cron, schedule2);
        
        Test.stopTest();
        
       // }

        List<Objectives__Share> objectiveShares = [
            Select UserOrGroupId
            From Objectives__Share
        ];

        Objectives__c objectif = [ Select Sub_Segment__c From Objectives__c Limit 1 ]; 
        
        List<Plant_Segment_Users__c> subsegUsers = [ Select User__c From Plant_Segment_Users__c where Product__c = :objectif.Sub_Segment__c ];
        
        Set<Id> stIds = new set<Id> ();
        for(Plant_Segment_Users__c psuser : subsegUsers){
            stIds.add(psuser.User__c);
        } 
        
        Integer nbrSTWhoShare = [
            Select count()
            From Objectives__Share
            Where UserOrGroupId In :stIds
        ];
        // Expected 2 because only two plantUsers have the same product_id as the objective's
       // System.assertEquals(2,nbrSTWhoShare);

      }
    
    static testmethod void testObjectiveMonthly(){
         //Creer des compte
        Country__c country = new Country__c(Name = 'France', Country_Code__c = 'FR');
        insert country;
    
        //Create Test Distribution Channel
        Distribution_Channel__c testDistrib = new Distribution_Channel__c(Name ='Test',Distribution_Channel_Code__c='test',Language_Key__c='test');
        insert testDistrib;
         Sales_Area__c testArea = new Sales_Area__c(Name='Test');
        insert testArea;
         Product_Sub_segment__c subProd = new Product_Sub_segment__c(
            Name = 'Iron Lotion pumps'
          );
          insert subProd;
         Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        insert acc;
         Product2 prod = new Product2(Name = 'bottle 50ml', Product_Sub_Segment__c = subProd.Id,
                                     Family = 'Bottle');
        insert prod;
        Objectives__c obj = new Objectives__c(Name='test', Sub_Segment__c =prod.id , Account__c = acc.Id, Date__c=Date.today());
          obj.Year_Objective__c=1200;
            insert obj;
        List<Objectives__c>lobj =[select Monthly_Objective_Cur__c,Monthly_Objective__c from Objectives__c ];
        AP01_Objective_Rules.ObjectiveMonthly_Objective_Cur(lobj);
        
    }
}