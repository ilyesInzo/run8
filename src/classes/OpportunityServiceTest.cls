/**
* Test class of OpportunityService
*
* @author MDK
* @date 09/10/2017
* @description The aim of this class is to test :
*    - all OpportunityService methods
*   
*/
@isTest
public class OpportunityServiceTest {

    @testSetup 
    private static void init() {

        final Integer TEST_SIZE = 10;

        //Create Some Users
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

       

        //Create second Account
        Account acc2 = TestFactory.newAccount(countries[0].Id,distCountry1.Id,salesArea.Id, state.Id, 'VAT2');
        acc2.Street__c = 'test';
        acc2.Type = 'Competitor';
        insert acc2;
  
        //Create opportunity
        

        //Create opportunity
        Opportunity opp2 = TestFactory.newOpportunity('Opp2', 'Qualification', null, null, acc2.Id);
        insert opp2;

        //Create some products for the bulk test
        Set<String> productNames = new set<String>();
        for (Integer i=0; i < TEST_SIZE + 1; i++) {
            productNames.add('name'+i);
        }
        List<Product2> products = TestFactory.newProducts(productNames);
        insert products;
        system.debug('testarthur : ' + [Select ProductCode from Product2 Where id = :products[0].id].ProductCode);
        system.debug('testarthur : ' + [Select ProductCode from Product2 Where id = :products[1].id].ProductCode);
        system.debug('testarthur : ' + [Select ProductCode from Product2 Where id = :products[2].id].ProductCode);
        system.debug('testarthur : ' + [Select ProductCode from Product2 Where id = :products[3].id].ProductCode);
        system.debug('testarthur : ' + [Select ProductCode from Product2 Where id = :products[4].id].ProductCode);
        system.debug('testarthur : ' + [Select ProductCode from Product2 Where id = :products[5].id].ProductCode);
        system.debug('testarthur : ' + [Select ProductCode from Product2 Where id = :products[6].id].ProductCode);
        system.debug('testarthur : ' + [Select ProductCode from Product2 Where id = :products[7].id].ProductCode);
        system.debug('testarthur : ' + [Select ProductCode from Product2 Where id = :products[8].id].ProductCode);
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
        Account acc1;
        System.runAs(stUsers[0]) {
             //Create one Account
            acc1 = TestFactory.newAccount(countries[0].Id,distCountry1.Id,salesArea.Id, state.Id, 'VAT1');
            acc1.Street__c = 'test';
            acc1.Type = 'Competitor';
            insert acc1;
            Opportunity opp1 = TestFactory.newOpportunity('Opp1', 'Qualification', null, null, acc1.Id);
            insert opp1;
            Quote quote1;
            quote1 = TestFactory.newQuote(null, Date.today(), 'Draft', opp1.Id);
            //quote1.OwnerId = stUsers[0].Id;
            insert quote1;
        }

        Quote quote2 = TestFactory.newQuote(null, Date.today(), 'Draft', opp2.Id);
        insert quote2;

        Sales_Team__c st = TestFactory.newSalesTeam(stUsers[0].Id, stUsers[1].Id, stUsers[2].Id, stUsers[3].Id);
        st.Valid_From__c = SalesService.YESTERDAY_DATE;
        insert st;

        //Create some Sales Allocations for the bulk test
        List<Sales_allocations__c> sas = new List<Sales_allocations__c>();
        for(Integer i=0; i < TEST_SIZE; i++) {
            Sales_Allocations__c sa = new Sales_Allocations__c();
            if (Math.mod(i,2) == 0 ) {
                //System.debug('Product2Id = '+products[i].id);
                sa = new Sales_Allocations__c(
                    Account__c              = acc1.id,
                    Product_sub_segment__c  = products[i].id,
                    Sales_team__c           = st.id,
                    Valid_To__c             = SalesService.FUTURE_DATE,
                    Valid_From__c           = SalesService.YESTERDAY_DATE
                );
            } else {
                //System.debug('Product2Id = '+products[i].id);
                sa = new Sales_Allocations__c(
                    Account__c              = acc2.id,
                    Product_sub_segment__c  = products[i].id,
                    Sales_team__c           = st.id,
                    Valid_To__c             = SalesService.FUTURE_DATE,
                    Valid_From__c           = SalesService.YESTERDAY_DATE
                );

            }            
            sas.add(sa);            
        }   
        insert sas;

        // Insert QLI with non admin user
        System.runAs(stUsers[0]) {
            Quote quote1 = [select Id from Quote where OwnerId = :stUsers[0].Id limit 1];
            QuoteLineItem qli1 = TestFactory.newQuoteLineItem(quote1.id,products[0].Id,pbEntries[0].Id);
            insert qli1;
        }

        // Insert QLI with admin user
        System.runAs(admUser) {
            QuoteLineItem qli2 = TestFactory.newQuoteLineItem(quote2.id,products[1].Id,pbEntries[1].Id);
            insert qli2;
        }

    }
   

    @isTest
    private static void testCharCheckerForOpportunityTriggerPositive(){

        Account acc = [Select Id From Account Limit 1];
        
        Opportunity opp1 = new Opportunity(
            Name = 'Test Opp 1', 
            AccountId = acc.Id, 
            StageName = 'Qualification', 
            CloseDate = Date.today()
        );
            
         Test.startTest();              
            Boolean triggersError = false;
            try{
                insert opp1;
            }catch(Exception e){
                triggersError = true;   
            }
      
        test.stopTest();
        
        //asserts
        system.assertEquals(false,triggersError);
    }
    
    @isTest
    private static void testCharCheckerForOpportunityTriggerNegative(){
         
        Account acc = [Select Id From Account Limit 1];
        
        Opportunity opp1 = new Opportunity(
            Name = 'Test Opp 无动为大无颠无倒 1', 
            AccountId = acc.Id, 
            StageName = 'Qualification', 
            CloseDate = Date.today()
        );
       
         Test.startTest();              
            Boolean triggersError = false;
            try{
                insert opp1;
            }catch(Exception e){
                triggersError = true;   
            }
      
        test.stopTest();
        
        //asserts
        system.assertEquals(true,triggersError);
    }


    @isTest
    private static void updateOpptyOwnerIdTest() {

        User newKam0 = [Select Id,LastName,FirstName From User Where Matricule_ADS__c = '1000'];

        User admUser = [Select Id,LastName,FirstName From User Where Matricule_ADS__c = '1'];

        User newKam1 = TestFactory.newKamUser(1004);
        insert newKam1;

        User newKam2 = TestFactory.newKamUser(1005);
        insert newKam2;

        // Fetch the Opportunity with QLI inserted by Kam User
        Opportunity opp = [
            Select
                KAMFullName__c,
                OwnerId
            From Opportunity
            Where Name = 'Opp1'
        ];

        // Check if the Kam has been set on the Opportunity
        System.assertEquals(newKam0.Id, opp.OwnerId);

        // Fetch the Opportunity with QLI inserted by Admin User
        Opportunity opp2 = [
            Select
                KAMFullName__c,
                OwnerId
            From Opportunity
            Where Name = 'Opp2'
        ]; 

        // Check if the ST's Kam has been set on the Opportunity
        System.debug('User adm Id = '+admUser.Id);
        System.debug('Kam Id = '+newKam0.Id);
        System.assertEquals(newKam0.Id, opp.OwnerId);

        // Fetch Sales Team to check the Opportunity Team
        Sales_Team__c st = [
            Select Kam__c,Manager__c
            From Sales_Team__c
            Limit 1
        ];

        // Fetch the Opportunity Team member
        OpportunityTeamMember oppTm = [
            Select 
                OpportunityId,
                UserId,
                TeamMemberRole,
                OpportunityAccessLevel
            From OpportunityTeamMember
            Where TeamMemberRole = 'Manager'
            And OpportunityId = :opp.Id    
        ];

        // Check if the Opportunity Team Member has been set
        System.assertEquals(oppTm.UserId, st.Manager__c);

        List<Sales_Allocations__c> sas = [Select Valid_To__c From Sales_Allocations__c];

        Test.startTest();

            // first update of the day : a new Sales Team is created and a Sales Allocation is archived
            st.Kam__c = newKam1.Id;
            update st;                    

            //Get the cloned Sales Team
            Sales_Team__c clonedSt = [
                Select KAM__c
                From Sales_Team__c
                Where Tech_Overlapped_SalesTeam__c = :st.Id
            ];

            System.assertEquals(newKam1.Id,clonedSt.KAM__c);

            // Fetch the Opportunity
            opp = [
                Select
                    KAMFullName__c,
                    OwnerId
                From Opportunity
                Where Name = 'Opp1'
            ];

            newKam1 = [Select Id,LastName,FirstName From User Where Matricule_ADS__c = '1004'];

            // Check if the Kam has not been updated on the Opportunity
            // because the batch has to run
            System.assertNotEquals(newKam1.Id, opp.OwnerId);

            //Run the batch
            ArchiveSalesAllocationsBatch batch = new ArchiveSalesAllocationsBatch();             
            Database.executeBatch(batch);

        Test.stopTest();
            
        // Fetch again the Opportunity updated
        /*opp = [
            Select
                KAMFullName__c,
                OwnerId
            From Opportunity
            Where Name = 'Opp1'
        ];

        newKam1 = [Select Id,LastName,FirstName From User Where Matricule_ADS__c = '1004'];

        // Check if the Kam has been updated on the Opportunity
        // after the batch execution
        System.assertEquals(newKam1.Id, opp.OwnerId); 

        // second update of the day : the Cloned Sales Team is modified only
        clonedSt.Kam__c = newKam2.Id;
        update clonedSt;   

        // Fetch the Sales Team's KAM
        clonedSt = [
            Select KAM__c,Manager__c
            From Sales_Team__c
            Where Id = :clonedSt.Id
        ];

        System.assertEquals(newKam2.Id,clonedSt.KAM__c);

        // Fetch the Opportunity updated
      /*  opp = [
                Select
                    KAMFullName__c,
                    OwnerId
                From Opportunity
                Where Name = 'Opp1'
        ];

        newKam2 = [Select Id,LastName,FirstName From User Where Matricule_ADS__c = '1005'];

        // Check if the Kam has been updated on the Opportunity
        System.assertEquals(newKam2.Id, opp.OwnerId); */

               
    }   
    
    /* @isTest
    private static void updateOpptyOwnerIdTest2() {

        User newKam0 = [Select Id,LastName,FirstName From User Where Matricule_ADS__c = '1000'];

        User admUser = [Select Id,LastName,FirstName From User Where Matricule_ADS__c = '1'];

        User newKam1 = TestFactory.newKamUser(1004);
        insert newKam1;

        User newKam2 = TestFactory.newKamUser(1005);
        insert newKam2;

		Opportunity opp = [
            Select
                KAMFullName__c,
                OwnerId
            From Opportunity
            Where Name = 'Opp1'
        ];


        // Fetch the Opportunity with QLI inserted by Admin User
        Opportunity opp2 = [
            Select
                KAMFullName__c,
                OwnerId
            From Opportunity
            Where Name = 'Opp2'
        ]; 

        // Check if the ST's Kam has been set on the Opportunity
        System.debug('User adm Id = '+admUser.Id);
        System.debug('Kam Id = '+newKam0.Id);
        System.assertEquals(newKam0.Id, opp2.OwnerId);

        // Fetch Sales Team to check the Opportunity Team
        Sales_Team__c st = [
            Select Kam__c,Manager__c
            From Sales_Team__c
            Limit 1
        ];


        Test.startTest();

            // first update of the day : a new Sales Team is created and a Sales Allocation is archived
            st.Kam__c = newKam1.Id;
            update st;                    

            //Get the cloned Sales Team
            Sales_Team__c clonedSt = [
                Select KAM__c
                From Sales_Team__c
                Where Tech_Overlapped_SalesTeam__c = :st.Id
            ];



            //Run the batch
            ArchiveSalesAllocationsBatch batch = new ArchiveSalesAllocationsBatch();             
            Database.executeBatch(batch);

        Test.stopTest();
            
        // Fetch again the Opportunity updated
        opp = [
            Select
                KAMFullName__c,
                OwnerId
            From Opportunity
            Where Name = 'Opp1'
        ];

        newKam1 = [Select Id,LastName,FirstName From User Where Matricule_ADS__c = '1004'];

        // second update of the day : the Cloned Sales Team is modified only
        clonedSt.Kam__c = newKam2.Id;
        update clonedSt;   

        // Fetch the Sales Team's KAM
        clonedSt = [
            Select KAM__c,Manager__c
            From Sales_Team__c
            Where Id = :clonedSt.Id
        ];

        System.assertEquals(newKam2.Id,clonedSt.KAM__c);

        // Fetch the Opportunity updated
        opp = [
                Select
                    KAMFullName__c,
                    OwnerId
                From Opportunity
                Where Name = 'Opp1'
        ];

        newKam2 = [Select Id,LastName,FirstName From User Where Matricule_ADS__c = '1005'];

        // Check if the Kam has been updated on the Opportunity
        System.assertEquals(newKam2.Id, opp.OwnerId); 

               
    }   */
    
     @isTest
    private static void updateOpptyOwnerId_liOppTest() {
        List<Opportunity> liOppToUpdate = [Select Id, ownerID, accountid,Sales_Allocation_Id__r.sales_team__r.kam__c,Sales_Allocation_Id__r.product_sub_segment__c  
                        FROM Opportunity where  Sales_Allocation_Id__c != null AND  Sales_Allocation_Id__r.sales_team__r.kam__c !=null AND Sales_Allocation_Id__r.valid_to__c >= TODAY 
                        limit 150];
        String prdcode = 'test' + 10;
        String prdId = [Select id from Product2 Where ProductCode = :prdcode].id;
        User newKam0 = [Select Id,LastName,FirstName From User Where Matricule_ADS__c = '1000'];
        Sales_Team__c  st = new Sales_Team__c(  kam__c= newKam0.id,
                                                valid_from__c =system.Today()   ,
                                                valid_to__c =system.Today()+100 );
        insert st;
        Sales_allocations__c sa2 = new Sales_allocations__c (Account__c = liOppToUpdate[0].AccountID,
                                                             valid_from__c =system.Today()  ,
                                                             valid_to__c =system.Today()+100, 
                                                             //product_sub_segment__c = liOppToUpdate[0].Sales_Allocation_Id__r.product_sub_segment__c ,
                                                             product_sub_segment__c = prdid,
                                                             sales_team__c = st.Id);
        insert sa2;
                  
        liOppToUpdate[0].Sales_Allocation_Id__c = sa2.ID;
        update      liOppToUpdate[0];
                
        Test.startTest();       
            OpportunityService.updateOpptyOwnerId(liOppToUpdate);
        Test.stopTest();  
        
        for(Opportunity opp: liOppToUpdate)
            system.assertEquals(opp.Sales_Allocation_Id__r.sales_team__r.kam__c,opp.ownerID);
               
    }
    
}