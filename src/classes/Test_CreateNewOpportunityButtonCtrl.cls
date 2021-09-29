@isTest
public class Test_CreateNewOpportunityButtonCtrl {


    @testSetup static void createData() {
        
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
        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        acc.street__c = 'Test';
        insert acc;

        
  
    }

    static testmethod void test_checkCreationAccess_true(){
        Account acc = [select Id from account limit 1];
        
        AccountTeamMember member = new AccountTeamMember (AccountId = acc.Id, UserId = UserInfo.getUserId()); 
        insert member; 
        
        Test.startTest();
           boolean result= CreateNewOpportunityButtonController.checkCreationAccess(acc.Id);
        Test.stopTest();
        System.assertEquals(result, true); 
     }

    static testmethod void test_checkCreationAccess_false(){
        
        Account acc = [select Id from account limit 1];
        Id IdU = UserInfo.getUserId(); 
        User usr = [select Id, Allow_Opportunity_Creation__c from User where Id =: IdU limit 1];
        usr.Allow_Opportunity_Creation__c = false; 
        update usr;
        Test.startTest();
           boolean result= CreateNewOpportunityButtonController.checkCreationAccess(acc.Id);
        Test.stopTest();
        System.assertEquals(result, false); 
     }



}