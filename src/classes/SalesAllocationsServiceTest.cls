/**
* Test class of SalesAllocationsService
*
* @author MDK
* @date 09/10/2017
* @description
*
*/
@isTest
private class SalesAllocationsServiceTest {

	// SOME METHODS ARE TESTED IN SALESSERVICETEST CLASS

	
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

		//Create country
        Country__c country = new Country__c(Name = 'France', Country_Code__c = 'FR');
        insert country;
    
        //Create Distribution Channel
        Distribution_Channel__c distCountry1 = new Distribution_Channel__c(Name ='Test1',Distribution_Channel_Code__c='Test1',Language_Key__c='Test1');
        insert distCountry1;
        
        //Create Sales Area
        Sales_Area__c salesArea = new Sales_Area__c(Name='Test');
        insert salesArea;

        // Create a State
        State__c state = TestFactory.newState('FRANCE','FR');
        insert state;

        //Create one Account for the bulk test
        Account acc1 = TestFactory.newAccount(country.Id,distCountry1.Id,salesArea.Id,state.Id);
        insert acc1;       

        //Create a Sales Team
        Sales_Team__c st1 = TestFactory.newSalesTeam(stUsers[0].id,stUsers[1].id,stUsers[2].id,stUsers[3].id);
        insert st1;

        //Create some products for the bulk test
        Product_Sub_segment__c subProduct = new Product_Sub_segment__c(
       	 		Name = 'Iron Lotion pumps'
	      	);
	      	insert subProduct;
        List<Product2> products = new List<Product2>();
        for(Integer i = 0; i < TEST_SIZE; i++) {
        	
        	Product2 prod = new Product2(	
        		Name = 'Bottle 50ml', 
                Family = 'Bottle'+i,
                Product_Sub_Segment__c = subProduct.Id
            );
            products.add(prod);
        }
        insert products;

        //Create one Sales Allocations
        Sales_Allocations__c sa = new Sales_Allocations__c(
        	Account__c				= acc1.id,
			Product_Sub_Segment__c 	= products[0].id,
			Sales_Team__c 			= st1.id,
			Valid_To__c				= SalesService.FUTURE_DATE
	    );
		insert sa;

	}
	
    /**
     * @description 
     * @param 
     * @return 
     */
	@isTest
	static void updateSalesAllocationsTest() {

		// Test an update of Sales Alocations
		Sales_Allocations__c saBeforeUpdate = [
			Select Account__c,Product_Sub_Segment__c,Sales_Team__c,Valid_To__c,Sales_Allocation_Unique_Checker__c
			From Sales_Allocations__c
			limit 1
		];

		Product2 prod = [
			Select Id
			From Product2
			Where Family = 'Bottle2'
			Limit 1
		];

		// Test an update Product_Sub_Segment__c of Sales Allocations
		saBeforeUpdate.Product_Sub_Segment__c = prod.Id;
		update saBeforeUpdate;


		Sales_Allocations__c saAfterUpdate = [
			Select Account__c,Product_Sub_Segment__c,Sales_Team__c,Valid_To__c,Sales_Allocation_Unique_Checker__c
			From Sales_Allocations__c
			limit 1
		];

		System.assertEquals(saAfterUpdate.Sales_Allocation_Unique_Checker__c,saAfterUpdate.Account__c +'_'+ prod.Id +'_'+String.valueOf(saAfterUpdate.Valid_To__c ));

		
		saBeforeUpdate = [
			Select Account__c,Product_Sub_Segment__c,Sales_Team__c,Valid_To__c,Sales_Allocation_Unique_Checker__c
			From Sales_Allocations__c
			limit 1
		];

		// Test an update Valid_To__c of Sales Allocations
		saBeforeUpdate.Valid_To__c = SalesService.CURRENT_DATE;
		update saBeforeUpdate;

		saAfterUpdate = [
			Select Account__c,Product_Sub_Segment__c,Sales_Team__c,Valid_To__c,Sales_Allocation_Unique_Checker__c
			From Sales_Allocations__c
			limit 1
		];

		System.assertEquals(saAfterUpdate.Sales_Allocation_Unique_Checker__c,saAfterUpdate.Account__c +'_'+ saAfterUpdate.Product_Sub_Segment__c +'_'+String.valueOf(SalesService.CURRENT_DATE));
		
	}
    
    @isTest
      public static void createChatterNotifTest(){
       
        //creation of Set<String> listUsersToNotif, String body
        Set<String> listuserinit = new Set<String>();
        List<User> listUsers = [select Id from User limit 1];
        for(User usr:listUsers){
            listuserinit.add(usr.Id);
        }
        //insert listuserinit;
        String body = 'test test notif';
        Test.startTest();
        SalesTeamService.getInstance().createChatterNotif(listuserinit,body);
        list<FeedItem> result = [select Id from FeedItem];
		System.assertNotEquals(result.size(), 0);
        Test.stopTest();
    }
    
    @isTest
    public static void uncheckUsersTest(){
        
        //creation of list user
        Set<String> listuserinit = new Set<String>();
        List<User> listUsers = [select Id, Update_Request_Sales_Team__c from User limit 1];
        for(User usr:listUsers){
            usr.Update_Request_Sales_Team__c = true;
            listuserinit.add(usr.Id);
        }
        Test.startTest();
        SalesTeamService.getInstance().uncheckUsers(listuserinit);
        User usr= [select Id, Update_Request_Sales_Team__c from user where Id = : listUsers[0].Id ];
        System.assertEquals(usr.Update_Request_Sales_Team__c , false);
        Test.stopTest();
    }
	
}