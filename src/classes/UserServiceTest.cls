@isTest
public class UserServiceTest {

    @testSetup 
    private static void init() {

        insert TestFactory.newUser('SALES - KAM', 1234);
        insert TestFactory.newUser('SALES - KAM', 12345);
        
    }

    @isTest
    static void getUserTest(){

        List<User> users = [
            Select Id 
            From User
        ];

        Set<Id> userIds = SObjectUtils.toSetOfId(users);
        UserService us = new UserService();
        Map<Id, User> usersById = us.getUser(userIds);
        usersById = us.getUser(null);
    }

    @isTest
    static void checkMatriculeADSUserSalesTest(){
                
        User user2 = [
            Select Matricule_ADS__c 
            From User 
            Where Matricule_ADS__c = '12345'
        ];
        
        // Test Insert with different Matricule    
        insert TestFactory.newUser('SALES - KAM', 4321);

        // Test 2 Inserts with different Matricule
        List<User> sales = new List<User> {
            TestFactory.newUser('SALES - KAM', 12),
            TestFactory.newUser('SALES - KAM', 13)
        };
        insert sales; 

        List<User> salesInserted = [
            Select Matricule_ADS__c
            From User
            Where Id In :sales
            Order by Matricule_ADS__c asc
        ];

        System.assertEquals(salesInserted[0].Matricule_ADS__c, '12');
        System.assertEquals(salesInserted[1].Matricule_ADS__c, '13');
            
        // Test Insert with the same Matricule
        try {
            insert TestFactory.newUser('SALES - KAM', 1234);    
        } catch (Exception e) {
            System.assertEquals(e.getMessage().contains('Duplicate record on User'), false);                        
        }

        // Test Update with the same Matricule
        try {
            user2.Matricule_ADS__c = '1234';
            update user2;
        } catch (Exception e) {
            System.assertEquals(e.getMessage().contains('Duplicate record on User'), false);            
        }

        // Test 2 Inserts with the same Matricule
        try {
            List<User> users = new List<User> {
                TestFactory.newUser('SALES - KAM', 123),
                TestFactory.newUser('SALES - KAM', 123)
            };
            insert users;    
        } catch (Exception e) {
            System.assertEquals(e.getMessage().contains('Duplicate record on User, Please review the Key : Matricule ADS'), false);                        
        } 
        
               
    }

}