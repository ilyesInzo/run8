/**
* Test class of ArchiveSalesAllocationsBatch
*
* @author MDK
* @date 09/10/2017
* @description 
*
* To Do :
*	- test an update DML exception
*/
@isTest
private class ArchiveSalesAllocationsBatchTest {

    // Functional tests are done in SalesServiceTest Class

    @testSetup 
	private static void init() {

		//Create Some Users
		List<User> stUsers = new List<User>();
		stUsers.add(TestFactory.newKamUser(1000));
		stUsers.add(TestFactory.newManagerUser(1001));
		stUsers.add(TestFactory.newAdditionalUser(1002));
		stUsers.add(TestFactory.newDirectorUser(1003));
		insert stUsers;

		//Create country
        Country__c country = new Country__c(Name = 'France', Country_Code__c = 'FR');
        insert country;
    
        //Create Distribution Channel
        Distribution_Channel__c distCountry1 = new Distribution_Channel__c(Name ='Test1',Distribution_Channel_Code__c='Test1',Language_Key__c='Test1');
        insert distCountry1;
        
        // Create a State
        State__c state = TestFactory.newState('FRANCE','FR');
        insert state;

        //Create Sales Area
        Sales_Area__c salesArea = new Sales_Area__c(Name='Test');
        insert salesArea;

        //Create two Account for the bulk test
        Account acc1 = TestFactory.newAccount(country.Id,distCountry1.Id,salesArea.Id, state.Id);
        insert acc1;       

        //Create a Sales Team
        Sales_Team__c st1 = TestFactory.newSalesTeam(stUsers[0].id,stUsers[1].id,stUsers[2].id,stUsers[3].id);
        insert st1;

		Product_Sub_segment__c prod2 = new Product_Sub_segment__c(
        	Name = 'Iron Lotion pumps'
      	);
      	insert prod2;

        //Create some products for the bulk test
        Product2 prod = new Product2(	
        	Name = 'Bottle 50ml', 
            Family = 'Bottle',            
            Product_Sub_Segment__c = prod2.Id
        );
        insert prod;

        //Create some Sales Allocations for the bulk test
	    Sales_Allocations__c sa = new Sales_Allocations__c(
	        account__c				= acc1.id,
			product_sub_segment__c 	= prod.id,
			sales_team__c 			= st1.id,
			Valid_From__c 			= Date.newInstance(1900, 1, 1),
			Valid_To__c				= SalesService.FUTURE_DATE,
			ToArchiveWithValidTo__c = SalesService.YESTERDAY_DATE,
			ToArchiveWithValidFrom__c = SalesService.YESTERDAY_DATE
	    ); 
		insert sa;	
	}

	@isTest
    static void testBatch() {

		Test.startTest();

		    // Test the default constructor
			Database.executeBatch(new ArchiveSalesAllocationsBatch());

		    String query = ''
		        + 'SELECT '
		        + '    ToArchiveWithValidFrom__c,'
		        + '    ToArchiveWithValidTo__c,'
		        + '    Account__c,'
		        + '    Product_Sub_Segment__c,'
		        + '    Tech_SalesTeam_Overlap__c '                                  
		        + 'FROM '
		        + '    Sales_Allocations__c '
		        + 'WHERE '
		        + '     ToArchiveWithValidTo__c != null '
		        + ' AND ToArchiveWithValidFrom__c != null';
			ArchiveSalesAllocationsBatch batch = new ArchiveSalesAllocationsBatch(query);
		    
		    // Test the getBatchName method
		    String batchName = batch.getBatchName(); 

		    // Test the ParentBatch addErrors methods
		    List<Account> accs = new List<Account> { new Account(Name='0'.repeat(300)) };
		    Database.SaveResult[] saveResults = Database.insert(accs, false);
		    batch.addErrors('Test Error');
		    batch.addErrors(saveResults, 'Test Error');
		    batch.addErrors(accs, saveResults, 'Test Error');

		    // Test the batch with a DUPLICATE VALUE ERROR (The same record has already been inserted above) << Plante mais doit être recoder
		    //try {
		    //	Database.executeBatch(batch);	
		    //} catch (DmlException e) {
		    	
		    //}
		    
		    		    
		    // Test the scheduler
		    ArchiveSalesAllocationsSchedulable scheduler = new ArchiveSalesAllocationsSchedulable();
		    List<Id> jobIds = ArchiveSalesAllocationsSchedulable.schedule(); 

		Test.stopTest();

	}

}