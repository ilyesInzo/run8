@isTest 
private class PlantSegmentServiceTest {
    /*
    *creating test data
    */
    @testSetup static void createTestData() {
        //create Accounts
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
                        
        //create opportunities
        //Get Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();
    
        Opportunity opp = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', CloseDate = Date.today()-1);
        insert opp;
        
        Product_Sub_segment__c subProd = new Product_Sub_segment__c(
        	Name = 'Iron Lotion pumps'
      	);
      	insert subProd;
        
        //create products
        Product2 prod = new Product2(Name = 'bottle 50ml', isActive=true,Family = 'Bottle', Product_Sub_Segment__c = subProd.Id);
        insert prod;
        
        Product2 prod2 = new Product2(Name = 'Tube 50ml', isActive=true,Family = 'Tube', Product_Sub_Segment__c = subProd.Id);
        insert prod2;
            
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id,UnitPrice = 10000, IsActive = true);
        insert pbe;
        
        //create quotes
        Quote q = new Quote(Total_Sales__c=1,pricebook2Id=pricebookId, Name = 'Test Quote 1', OpportunityId = opp.Id, RFQ_Reception_Date__c = Date.today(),First_Delivery_Date__c=Date.today());
        insert q;
        
       /* Opportunity op = [select id, syncedQuoteId,Total_Amount__c from opportunity where id = :opp.id];
        op.SyncedQuoteId =  q.Id;
        update op;
        */     
        //create QuoteLineItems
        quotelineitem qli = new Quotelineitem(ID_Calculette__c='XX',Sales_price_per_1000_KCur__c=10,Tooling_sales_price_k_Cur__c=10,QuoteId= q.id, PricebookEntryId=pbe.id,Production_Cluster__c = 'Albea China',Production_Plant__c ='Hong Kong PC',Product2ID=prod.id ,Quantity=20, UnitPrice=10, Ref_RFQ__c = 'Test');
        insert qli;
                
        //Create plant and cluster
        Plant_and_Cluster__c plantandcluster = new Plant_and_Cluster__c(Name= 'Hong Kong PC',Plant_Code__c= '1234');
        insert plantandcluster;
        
        //Create Plant seg users
        List<USer> users = [select id , name from user where profile.name in ('SALES - KAM', 'Plant') and isactive = true];
        
        RecordType recTypePlant   = [select id, name from recordtype where name = 'Plant' and sobjecttype ='Plant_Segment_Users__c' limit 1];
        RecordType recTypeSegUser = [select id, name from recordtype where name = 'Sub Segment' and sobjecttype ='Plant_Segment_Users__c' limit 1];
       
        Plant_Segment_Users__c plsegUsr1 = new Plant_Segment_Users__c(Plant_and_Cluster__c=plantandcluster.id ,User__c=users[0].id , recordTypeId = recTypePlant.Id   ); 
        insert plsegUsr1;
        Plant_Segment_Users__c plsegUsr2 = new Plant_Segment_Users__c(Product__c=prod.id ,User__c=users[1].id ,recordTypeId =  recTypeSegUser.id  ); 
        insert plsegUsr2;
        
        //Create account/opportunity team members
        AccountTeamMember       accTM1 = new AccountTeamMember(AccountId=acc.id ,UserId=users[0].id ,TeamMemberRole='Plant'   );
        AccountTeamMember       accTM2 = new AccountTeamMember(AccountId=acc.id ,UserId=users[1].id ,TeamMemberRole='Product'   );
        
        OpportunityTeamMember   oppTM1 = new OpportunityTeamMember(OpportunityId=opp.id ,UserId=users[0].id ,TeamMemberRole='Plant'   );
        OpportunityTeamMember   oppTM2 = new OpportunityTeamMember(OpportunityId=opp.id ,UserId=users[1].id ,TeamMemberRole='Product'   );
        
        insert accTM1;
        insert oppTM1;
        insert accTM2;
        insert oppTM2;
    }
    
    /*
    * Delete a plant segment user with RecordType == Plant 
    */
    static testMethod void plantAndClusterDeletion() {
       
        Plant_Segment_Users__c plsegUsrPlant = [select id, Plant_and_Cluster__c,User__c, recordType.Name 
                                                from Plant_Segment_Users__c 
                                                where recordType.Name ='Plant'];

        Integer nbAcc = [select Id from AccountTeamMember where UserId = :plsegUsrPlant.User__c ].size();
        Integer nbOpp = [select Id from OpportunityTeamMember where UserId = :plsegUsrPlant.User__c ].size();
        
        Test.startTest();
            delete plsegUsrPlant ;  
        Test.stopTest();
        
        System.assertEquals(nbAcc -1, [select Id from AccountTeamMember where UserId = :plsegUsrPlant.User__c and TeamMemberRole='Plant'].size());
        System.assertEquals(nbOpp -1, [select Id from OpportunityTeamMember where UserId = :plsegUsrPlant.User__c and TeamMemberRole='Plant'].size());
        
    }
    
    /*
    * Delete a plant segment user with RecordType ==  Sub Segment  
    */
    static testMethod void prodSubSegDeletion() {
       Plant_Segment_Users__c plsegUsrProdSubSeg = [select id, Plant_and_Cluster__c,User__c, Product__c,recordType.Name 
                                                from Plant_Segment_Users__c 
                                                where recordType.Name ='Sub Segment'];

        Integer nbAcc = [select Id from AccountTeamMember where UserId = :plsegUsrProdSubSeg.User__c ].size();
        Integer nbOpp = [select Id from OpportunityTeamMember where UserId = :plsegUsrProdSubSeg.User__c ].size();
        
        Test.startTest();
            delete plsegUsrProdSubSeg ; 
        Test.stopTest();
        
        System.assertEquals(nbAcc -1, [select Id from AccountTeamMember     where UserId = :plsegUsrProdSubSeg.User__c and TeamMemberRole='Product'].size());
        System.assertEquals(nbOpp -1, [select Id from OpportunityTeamMember where UserId = :plsegUsrProdSubSeg.User__c and TeamMemberRole='Product'].size());
    }
    
     /*
    * Delete records with plant segment user with RecordType ==  Sub Segment && Plant
    */
    static testMethod void mixteDeletion() {
         List<id> idplsegUsrs = new list<id>();
         
         List<Plant_Segment_Users__c> lipls = [select id, Plant_and_Cluster__c,User__c, Product__c,recordType.Name 
                                                from Plant_Segment_Users__c 
                                                where recordType.Name in ('Sub Segment','Plant')];
         
         for(Plant_Segment_Users__c plsg : lipls ){
            idplsegUsrs.add(plsg.User__c);
         }
       
        Test.startTest();
            delete lipls ;  
        Test.stopTest();
        
        System.assertEquals(0, [select Id from AccountTeamMember    where UserId in :idplsegUsrs and TeamMemberRole='Product'].size());
        System.assertEquals(0, [select Id from OpportunityTeamMember where UserId in :idplsegUsrs and TeamMemberRole='Product'].size());
        
        System.assertEquals(0, [select Id from AccountTeamMember    where UserId in :idplsegUsrs and TeamMemberRole='Plant'].size());
        System.assertEquals(0, [select Id from OpportunityTeamMember where UserId in :idplsegUsrs and TeamMemberRole='Plant'].size());
        
    }
    
    
    /*
     * Add Plant user segment
     * 
     */
   
    static testMethod void PlantUserSegAccOppTeamTest() {
        List<id> idplsegUsrs = new list<id>();
         
         List<Plant_Segment_Users__c> lipls = [select id, Plant_and_Cluster__c,User__c, Product__c,recordType.Name,Plant_Segment_Users__c.Plant_and_Cluster__r.Name 
                                                from Plant_Segment_Users__c 
                                                where recordType.Name in ('Sub Segment','Plant')];
         
         for(Plant_Segment_Users__c plsg : lipls ){
            idplsegUsrs.add(plsg.User__c);
         }
       
        Test.startTest();
            PlantSegmentService.PlantUserSegAccOppTeam(lipls);  
        Test.stopTest();
        
        System.assertEquals(1, [select Id from AccountTeamMember    where UserId in :idplsegUsrs and TeamMemberRole='Product'].size());
        System.assertEquals(1, [select Id from OpportunityTeamMember where UserId in :idplsegUsrs and TeamMemberRole='Product'].size());
        
        System.assertEquals(1, [select Id from AccountTeamMember    where UserId in :idplsegUsrs and TeamMemberRole='Plant'].size());
        System.assertEquals(1, [select Id from OpportunityTeamMember where UserId in :idplsegUsrs and TeamMemberRole='Plant'].size());
        
    }


    
    /*
    *  
    */
    static testMethod void testSchClass() {    
                
        Test.startTest();
            Datetime sysTime = System.now().addSeconds( 900 );      
                String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        
                System.schedule( 'AccountTeamMembersDeletion ' + sysTime, chronExpression, new SCH_BatchDeletionAccOppTM(new set<id>(),new set<id>(), true,'AccountTeamMember')  );
        Test.stopTest();
        
    }
}