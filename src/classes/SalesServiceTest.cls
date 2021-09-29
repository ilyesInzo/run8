/**
* Test class of SalesService
*
* @author MDK
* @date 09/10/2017
* @description The aim of this class is to test :
*		From SalesTeamTriggerHandler :
*			SalesTeamService.resetSalesTeam method
*			SalesTeamService.cloneSalesTeam method
*			SalesTeamService.updateSalesTeam method	
*		From SalesAllocationsTriggerHandler :
*			SalesAllocationsService.linkClonedSalesTeamsToSalesAllocations method
*			SalesAllocationsService.setSalesAllocationsFields method
*		    setSalesAllocationsFields
*		The ArchiveSalesAllocationsBatch
*
* To Do
* 	- test 2 updates the same day
*	- test update of someone else as a KAM	
*/
@isTest
private class SalesServiceTest {

    
    @testSetup 
	private static void init() {

		final Integer TEST_SIZE = 40;

		//Create Some Users
		List<User> stUsers = new List<User>();
		stUsers.add(TestFactory.newKamUser(1000));
		stUsers.add(TestFactory.newManagerUser(1001));
		stUsers.add(TestFactory.newAdditionalUser(1002));
		stUsers.add(TestFactory.newDirectorUser(1003));
		stUsers.add(TestFactory.newKamUser(1004));
		stUsers.add(TestFactory.newDirectorUser(1005));
		stUsers.add(TestFactory.newManagerUser(1006));
		stUsers.add(TestFactory.newAdditionalUser(1007));
		stUsers.add(TestFactory.newDirectorUser(1008));
		stUsers.add(TestFactory.newKamUser(1009));
		stUsers.add(TestFactory.newDirectorUser(1010));		
		insert stUsers;
        

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

        //Create one Account for the bulk test
        Account acc1 = TestFactory.newAccount(countries[0].Id,distCountry1.Id,salesArea.Id, state.Id, 'VAT1');
        insert acc1;

        //Create one Account for the bulk test
        Account acc2 = TestFactory.newAccount(countries[0].Id,distCountry1.Id,salesArea.Id, state.Id, 'VAT2');
        insert acc2;  

        //Create opportunity
        Opportunity opp1 = TestFactory.newOpportunity('Opp1', 'Qualification', null, null, acc1.Id);
        opp1.OwnerId = stUsers[9].Id;
        insert opp1;

        //Create opportunity
        Opportunity opp2 = TestFactory.newOpportunity('Opp2', 'Qualification', null, null, acc2.Id);
        opp2.OwnerId = stUsers[0].Id;
        insert opp2;

        //Create a Sales Team
        Sales_Team__c st1 = TestFactory.newSalesTeam(stUsers[0].id,stUsers[1].id,stUsers[2].id,stUsers[3].id,'Test Team 1','1111');
        st1.Valid_From__c = SalesService.YESTERDAY_DATE;
        insert st1;

        //Create a Sales Team
        Sales_Team__c st2 = TestFactory.newSalesTeam(stUsers[4].id,stUsers[6].id,stUsers[7].id,stUsers[8].id,'Test Team 2','2222');
        st2.Valid_From__c = SalesService.YESTERDAY_DATE;
        insert st2;

        //Create some products for the bulk test
        Set<String> productNames = new set<String>();
        for (Integer i=0; i < TEST_SIZE; i++) {
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

        //Create opportunities
        /*List<Opportunity> opps = new List<Opportunity>();
        for(Integer i=0; i < TEST_SIZE; i++) {
            Opportunity opp = TestFactory.newOpportunity('OppBulk'+i, 'Qualification', null, null, acc1.Id);
            opps.add(opp);
        }
        insert opps;*/

        //Create some Sales Allocations for the bulk test
        List<Sales_allocations__c> sas = new List<Sales_allocations__c>();
        for(Integer i=0; i < TEST_SIZE; i = i+2) {
            Sales_Allocations__c sa = new Sales_Allocations__c();
            sa = new Sales_Allocations__c(
                Account__c              = acc1.id,
                Product_sub_segment__c  = products[i].id,
                Sales_team__c           = st1.id,
                Valid_To__c             = SalesService.FUTURE_DATE,
                Valid_From__c           = SalesService.YESTERDAY_DATE
            );
            sas.add(sa);
        }
        for(Integer i=1; i < TEST_SIZE; i = i+2) {
            Sales_Allocations__c sa = new Sales_Allocations__c();
            sa = new Sales_Allocations__c(
                Account__c              = acc2.id,
                Product_sub_segment__c  = products[i].id,
                Sales_team__c           = st2.id,
                Valid_To__c             = SalesService.FUTURE_DATE,
                Valid_From__c           = SalesService.YESTERDAY_DATE
            ); 
            sas.add(sa);             
        }   
        insert sas; 
	}
	
    /**
     * @description 
     * @param 
     * @return 
     */
	@isTest
	static void updateSalesTeamTest() {

		Test.startTest();

			System.debug(LoggingLevel.ERROR,'SalesTeamServiceTest.updateSalesTeamTest : Number of Queries used in this apex code : ' + Limits.getQueries());
            System.debug(LoggingLevel.ERROR,'SalesTeamServiceTest.updateSalesTeamTest : Number of rows queried in this apex code : ' + Limits.getQueryRows());
            System.debug(LoggingLevel.ERROR,'SalesTeamServiceTest.updateSalesTeamTest : Number of DML done : ' +  Limits.getDMLRows());

			AggregateResult nbrSa = [
				Select count(id) nbrSa
                From Sales_Allocations__c 
                //Group by Sales_Team__c
            ];

            System.debug(LoggingLevel.ERROR,'SalesTeamServiceTest.updateSalesTeamTest : Number of Sales Allocations = '+integer.valueOf(nbrSa.get('nbrSa')));

			// Fetch a product
			Product2 prod = [
				Select Id
				From Product2
				Limit 1
			];

			// Fetch the Sales Team
			List<Sales_Team__c> sts = [
				Select Id,Name,Sales_Team_Key__c,KAM__c,Director__c,Valid_From__c 
				From Sales_Team__c
			];

			// Keep the original values
			Id idBeforeUpdate = sts[0].Id;
			Sales_Team__c stBeforeUpdate = sts[0].clone();

			// Fetch the Sales Allocations
			Sales_Allocations__c saBeforeUpdate = [
				Select 
					Sales_Team__c,
					Valid_From__c,
					Valid_To__c,
					Sales_Allocation_Unique_Checker__c,
					Tech_SalesTeam_Overlap__c,
					ToArchiveWithValidTo__c,
					ToArchiveWithValidFrom__c,
					Account__c,
					Product_Sub_Segment__c
				From Sales_Allocations__c
				Where Product_Sub_Segment__c = :prod.Id
			];	

			User user = [Select Id From User Where Matricule_ADS__c = '1004' limit 1];

			// We change of KAM user of one of the Sales Team
			sts[0].KAM__c = user.Id;
			update sts;

			// Get the cloned Sales Team
        	Sales_team__c clonedSt = [
        		Select 
	            	Sales_Team__c,
	            	KAM__c,
	            	Name,
	            	Sales_team_Description__c,
	            	Valid_From__c,
	            	Valid_To__c,
	            	Tech_Overlapped_SalesTeam__c
	            From Sales_Team__c
	            Where Tech_Overlapped_SalesTeam__c = :sts[0].Id
            ];

            // Unit test : Check the cloned ST's values
			System.assertEquals(clonedSt.Sales_Team__c, '1111');
			System.assertEquals(clonedSt.Valid_From__c, SalesService.CURRENT_DATE);
			System.assertEquals(clonedSt.Valid_To__c, SalesService.FUTURE_DATE);
			System.assertEquals(clonedSt.Name, stBeforeUpdate.Name);

			// Get the updated Sales Team
			Sales_Team__c updatedSt = [
				Select Valid_To__c,Valid_From__c,KAM__c,Name 
				From Sales_Team__c 
				Where Id = :sts[0].Id 
				Limit 1
			];

			// Unit test : check the old ST's values
			System.assertEquals(updatedSt.Valid_From__c, stBeforeUpdate.Valid_From__c);
			System.assertEquals(updatedSt.Valid_To__c, SalesService.YESTERDAY_DATE);
			System.assertEquals(updatedSt.KAM__c, stBeforeUpdate.KAM__c);			
			System.assertEquals(updatedSt.Name, stBeforeUpdate.Name +'_'+ SalesService.YESTERDAY_DATE);

			// Fetch the Sales Allocations updated
			Sales_Allocations__c saAfterUpdate = [
				Select 
					Sales_Team__c,
					Valid_From__c,
					Valid_To__c,
					Product_Sub_Segment__c,
					Sales_Allocation_Unique_Checker__c,
					Tech_SalesTeam_Overlap__c,
					ToArchiveWithValidTo__c,
					ToArchiveWithValidFrom__c
				From Sales_Allocations__c
				Where Id = :saBeforeUpdate.Id
			];

			// Unit test : check the Sales Allocations linked to cloned Sales Team
			System.assertEquals(saAfterUpdate.Valid_From__c, SalesService.CURRENT_DATE);		         		
    	 	System.assertEquals(saAfterUpdate.Sales_Allocation_Unique_Checker__c, saBeforeUpdate.Account__c +'_'+ saBeforeUpdate.Product_Sub_Segment__c +'_'+String.valueOf(saBeforeUpdate.Valid_To__c));
    	 	System.assertEquals(saAfterUpdate.Tech_SalesTeam_Overlap__c, saBeforeUpdate.Sales_Team__c);
    	 	System.assertEquals(saAfterUpdate.ToArchiveWithValidTo__c, SalesService.YESTERDAY_DATE);
    	 	System.assertEquals(saAfterUpdate.ToArchiveWithValidFrom__c, saBeforeUpdate.Valid_From__c);

    	 	
    	 	// Fetch the user
    	 	User user2 = [Select Id From User Where Matricule_ADS__c = '1005' limit 1];
			// We change of Director user to test the Exception
			clonedSt.Director__c = user2.Id;
			try {
				update clonedSt;
			} catch (DmlException e) {    
	    		System.assertEquals(e.getMessage().contains(System.Label.SALESALLOCATION_ARCHIVE_ERRORMSG),true);
			}
			
			//Run the batch
        	ArchiveSalesAllocationsBatch batch = new ArchiveSalesAllocationsBatch();
            
           	// Test the getBatchName method
            String batchName = batch.getBatchName(); 

            // Test the batch
            Database.executeBatch(batch);

            System.debug(LoggingLevel.ERROR,'SalesTeamServiceTest.updateSalesTeamTest : Number of Sales Allocations = '+integer.valueOf(nbrSa.get('nbrSa')));

        Test.stopTest();

	 	//Fetch the Sales Allocations archived
		Sales_Allocations__c saArchived = [
			Select 
				Sales_Team__c,
				Valid_From__c,
				Valid_To__c,
				Sales_Allocation_Unique_Checker__c,
				Tech_SalesTeam_Overlap__c,
				ToArchiveWithValidTo__c,
				ToArchiveWithValidFrom__c,
				Account__c,
				Product_Sub_Segment__c
			From Sales_Allocations__c
			Where Product_Sub_Segment__c = :prod.Id
			And Valid_To__c = :SalesService.YESTERDAY_DATE
		];


		// Unit test : check the Sales Allocations archived
		System.assertEquals(saArchived.Valid_From__c, saBeforeUpdate.Valid_From__c);
		System.assertEquals(saArchived.Valid_To__c, SalesService.YESTERDAY_DATE);
		System.assertEquals(saArchived.Account__c, saBeforeUpdate.Account__c);
		System.assertEquals(saArchived.Product_Sub_Segment__c, saBeforeUpdate.Product_Sub_Segment__c);
		System.assertEquals(saArchived.Sales_Team__c, idBeforeUpdate);

		nbrSa = [
			Select count(id) nbrSa
            From Sales_Allocations__c 
            //Group by Sales_Team__c
        ];

        System.debug(LoggingLevel.ERROR,'SalesTeamServiceTest.updateSalesTeamTest : Number of Sales Allocations = '+integer.valueOf(nbrSa.get('nbrSa')));

        System.debug(LoggingLevel.ERROR,'SalesTeamServiceTest.updateSalesTeamTest : Number of Queries used in this apex code : ' + Limits.getQueries());
       	System.debug(LoggingLevel.ERROR,'SalesTeamServiceTest.updateSalesTeamTest : Number of rows queried in this apex code : ' + Limits.getQueryRows());
        System.debug(LoggingLevel.ERROR,'SalesTeamServiceTest.updateSalesTeamTest : Number of DML done : ' +  Limits.getDMLRows());
	}


	@isTest
	static void duplicateAllocationsTest(){
		/********* DEBUT TEST DATA  creation... *******/		

        
        //Select Test Accounts
        Account acc = [
        	Select Id
        	From Account
        	Where VAT_Code__c = 'VAT1'
        ];
        
        //Select Sales Teams
        List<Sales_Team__c> teams = [
        	Select Id, Name, Sales_Team__c
        	From Sales_Team__c
        ];        
       
        //Get products
        List<Product2> prod = [
        	Select Id
        	From Product2
        ];	         			
		
		//test duplicates
		//create duplicate record 
	 	List<Sales_allocations__c> salesAllocDups = new List<Sales_allocations__c>();		
		salesAllocDups.add(new Sales_allocations__c(
			account__c				= acc.id,
			product_sub_segment__c 	= prod[0].id,
			sales_team__c 			= teams[0].id) 
		) ;				
				
		Database.SaveResult[] srList = Database.insert(salesAllocDups, false);		       			
		Boolean errorExists = false;
		for (Database.SaveResult sr : srList) {
			if(sr.isSuccess())
				continue;
			else 
				errorExists = true;
		}
		
		System.AssertEquals(errorExists,true);
		
	}
	
	/*
	*
	*/
	@isTest
    static void processAllocationTest() {
    
        //Select Test Accounts
        List<Account> accounts = [
        	Select Id
        	From Account
        ];

        //Select Users
        List<User> users = [
        	Select Id, Matricule_ADS__c, FirstName, LastName
        	From User
        	Where Matricule_ADS__c In ('1000','1001','1002','1003','1004','1005','1006','1007','1008','1009','1010')
        	Order By Matricule_ADS__c Asc
        ]; 
        
        //Select Sales Teams
        List<Sales_Team__c> teams = [
        	Select Id, Name, Sales_Team__c
        	From Sales_Team__c
        ];        
       
        //Get products
        List<Product2> products = [
        	Select Id
        	From Product2
        ];	

        //Get opportunity
        Opportunity opp = [
        	Select Id
        	From Opportunity
            Where Name = 'Opp1'
        ];	

        Map<Object, SObject> pbEntrieIdByProductId = SObjectUtils.toMap([Select Id,Product2Id From PricebookEntry],'Product2Id'); 
        
        //Create Plant Record
        Plant_and_Cluster__c testPlant1 = new Plant_and_Cluster__c();
        testPlant1.Name = 'Hong Kong PC';
        testPlant1.Cluster_Name__c = 'ACH';
        testPlant1.Plant_Code__c = 'HG';
        
        insert testPlant1;
        
        //Create Plant User
        Plant_Segment_Users__c plantUser1 = new Plant_Segment_Users__c();
        plantUser1.Plant_and_Cluster__c = testPlant1.id;
        plantUser1.User__c = users[9].id;
        
        insert plantUser1;
        
        Plant_Segment_Users__c plantUser2 = new Plant_Segment_Users__c();
        plantUser2.Product__c = products[0].id;
        plantUser2.User__c = users[9].id;
        
        insert plantUser2;

        // Update Account Team before the test
        Id batchJobId3 = Database.executeBatch(new BA01_Sales_Team_Sharing()); 
        Id batchJobId4 = Database.executeBatch(new BA01_Sales_Team_Sharing_All());

        

        Test.startTest();

            // Update the Teams
            teams[0].KAM__c = users[9].Id;
            teams[0].Manager__c = users[6].Id;
            update teams[0];   

            teams[1].KAM__c = users[9].id;        
            teams[1].Director__c = users[10].id;        
            update teams[1];

            System.runAs(users[9]){

                Quote q1 = TestFactory.newQuote(null, Date.today(), 'Draft', opp.Id);
                insert q1;  
                                    
                //Create QuoteLine Item with different Allocation Sub Segment
                QuoteLineItem qli1 = TestFactory.newQuoteLineItem(q1.Id, products[0].Id, pbEntrieIdByProductId.get(products[0].Id).Id);
                insert qli1; 


            }

            // Test the SCH_DailyBatch scheduler which run the PlantUserAccOppTeam_Batch
            SCH_DailyBatch sheduler1 = new SCH_DailyBatch();
            String cron = '0 0 8 * * ?'; 
            String jobId = system.schedule('Test SCH_DailyBatch', cron, sheduler1);   
               
            CronTrigger ct = [
                Select Id, CronExpression, TimesTriggered, NextFireTime  
                From CronTrigger 
                Where id = :jobId
            ];

            System.assertNotEquals(ct, null);

            // Test the PlantUserAccOppTeam_Sched scheduler which run the PlantUserAccOppTeam_Batch
            PlantUserAccOppTeam_Sched sheduler2 = new PlantUserAccOppTeam_Sched();
            jobId = system.schedule('Test PlantUserAccOppTeam_Sched', cron, sheduler2);   
               
            ct = [
                Select Id, CronExpression, TimesTriggered, NextFireTime  
                From CronTrigger 
                Where id = :jobId
            ];

            System.assertNotEquals(ct, null);
            

            Id batchJobId = Database.executeBatch(new PlantUserAccOppTeam_Batch(), 200);
            Id batchJobId2 = Database.executeBatch(new PlantUserAccTeam_ALLQuoteLineItems_Batch(), 200);
            batchJobId3 = Database.executeBatch(new BA01_Sales_Team_Sharing()); 
            batchJobId4 = Database.executeBatch(new BA01_Sales_Team_Sharing_All());

        Test.stopTest();

        // Fetch the Opportunity updated
        opp = [
                Select
                    KAMFullName__c,
                    OwnerId
                From Opportunity
                Where Id = :opp.Id
        ];

        // Check if the Kam has been updated on the Opportunity
        System.assertEquals(users[9].Id, opp.OwnerId); 
    }
}