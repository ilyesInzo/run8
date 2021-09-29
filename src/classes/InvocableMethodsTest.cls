/**
 * [ InvocableMethodsTest information : 
 * This class is used to test Invocable methods used in process builders ]
 */ 
@isTest 
public class InvocableMethodsTest {
	//create test data
	@testSetup 
    private static void init() {
        List<Profile> ps = [select id, name from Profile where name = 'SALES - KAM' limit 1];    
        List<User> liUsersToInsert = new List<User>();
        
        //user with check field for salesteam      
        User userSTChecked = TestFactory.newUser('checkedST', 'checkedST',  'SALES - KAM',  true,true,  true,  true, 1245, ps[0].id);
        userSTChecked.Update_Request_Sales_Team__c = true;
        liUsersToInsert.add(userSTChecked);
        
        //user with check field for salesalloc      
        User userSAChecked = TestFactory.newUser('checkedAlloc', 'checkedAlloc',  'SALES - KAM',  true,true,  true,  true, 2345, ps[0].id);
        userSAChecked.Update_request_Sales_Alloc__c = true;
        liUsersToInsert.add(userSAChecked);
        
        //user with uncheck field for salesteam      
        User userSTunChecked = TestFactory.newUser('uncheckedST', 'uncheckedST',  'SALES - KAM',  true,true,  true,  true, 1045, ps[0].id);
        liUsersToInsert.add(userSTunChecked);
                
       	insert liUsersToInsert;
    }//end create test data
    
	//test checkRequestSalesTeam
    @isTest
    static void uncheckRequestSalesTeam_test(){
        List<User> usersBeforeUpdate = [Select Id,Update_Request_Sales_Team__c, profileID From User 
                                       where Matricule_ADS__c= '1245' and Profile.Name='SALES - KAM' limit 1 ] ;       	
       	Test.startTest();
        	checkUpdateRequestSalesTeam.unCheckField(usersBeforeUpdate);
        Test.stopTest();
        
        List<User> usersAfterUpdate = [Select Id,Update_Request_Sales_Team__c, profileID From User 
                                       where Matricule_ADS__c= '1245' and Profile.Name='SALES - KAM' limit 1];
        //Verify that the user record has been updated
        system.assert(!usersAfterUpdate[0].Update_Request_Sales_Team__c);
    }
    
    //test unCheckUpdateRequestSalesAllocation
    @isTest
    static void uncheckRequestSalesAllocation_test(){
        List<User> usersBeforeUpdate = [Select Id,Update_Request_Sales_alloc__c, profileID From User 
                                       where Matricule_ADS__c= '2345' and Profile.Name='SALES - KAM' limit 1 ] ;       	
       	
        unCheckUpdateRequestSalesAllocation.unCheckField(usersBeforeUpdate);
        
        List<User> usersAfterUpdate = [Select Id,Update_request_Sales_Alloc__c, profileID From User 
                                       where Matricule_ADS__c= '2345' and Profile.Name='SALES - KAM' limit 1];
        //Verify that the user record has been updated
        system.assert(!usersAfterUpdate[0].Update_Request_Sales_alloc__c);
    }
    
     /*test CheckUpdateRequestSalesAllocation
    @isTest
    static void checkRequestSalesAlloc_test(){
        List<User> usersBeforeUpdate = [Select Id,Update_Request_Sales_alloc__c, profileID From User 
                                       where Matricule_ADS__c= '1045' and Profile.Name='SALES - KAM' limit 1 ] ;       	
       	test.startTest();
        	checkUpdateRequestSalesAllocation.CheckField(usersBeforeUpdate);
        test.stopTest();
        
        List<User> usersAfterUpdate = [Select Id,Update_request_Sales_Alloc__c, profileID From User 
                                       where Matricule_ADS__c= '1045' and Profile.Name='SALES - KAM' limit 1];
        //Verify that the user record has been updated
        system.assert(!usersAfterUpdate[0].Update_Request_Sales_alloc__c);
    }*/
    
    /*test CheckUpdateRequestSalesTeam
    @isTest
    static void checkRequestSalesTeam_test(){
        List<User> usersBeforeUpdate = [Select Id,Update_Request_Sales_team__c, profileID From User 
                                       where Matricule_ADS__c= '1045' and Profile.Name='SALES - KAM' limit 1 ] ;       	
       	
       	Test.startTest();
        	//checkUpdateRequestSalesTeam.unCheckField(usersBeforeUpdate);
        Test.stopTest(); 
        	List<User> usersAfterUpdate = [Select Id,Update_request_Sales_team__c, profileID From User 
                                       where Matricule_ADS__c= '1045' and Profile.Name='SALES - KAM' limit 1];
        //Verify that the user record has been updated
        //system.assert(!usersAfterUpdate[0].Update_Request_Sales_team__c);
    }*/
}