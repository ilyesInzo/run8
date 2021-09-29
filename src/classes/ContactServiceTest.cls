/**
* Test class of ContactService
*
* @author MDK
* @date 09/10/2017
* @description The aim of this class is to test :
*    - all ContactService methods
*   
*/
@isTest
private class ContactServiceTest {

	@testSetup 
    private static void init() {

        final Integer TEST_SIZE = 10;

        //Create Some Users
        List<User> stUsers = new List<User>();
        stUsers.add(TestFactory.newKamUser(1000));
        stUsers.add(TestFactory.newManagerUser(1001));   
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
        Account acc1 = TestFactory.newAccount(countries[0].Id,distCountry1.Id,salesArea.Id, state.Id);
        acc1.Name = AP00_UtilityConstants.ACCOUNT_GAMIFICATION_ACCOUNT_NAME;

        insert acc1;  
        
        
        Badge__c b1 = new Badge__c(Name= AP00_UtilityConstants.BADGE_CONTACT_CREATION,
                                   Badge_family__c='Contact',
                                   Points_to_win__c='150',
                                   Points_By_Action__c ='5'
                                  );
        Badge__c b2 = new Badge__c(Name = AP00_UtilityConstants.BADGE_CONTACT_UPDATE,
                                   Badge_family__c='Contact',
                                   Points_to_win__c='150',
                                   Points_By_Action__c ='25'
                                  );
        insert new List<Badge__c>{b1,b2};
    }

	@isTest 
    private static void constructorTest() {
        ContactService.getInstance();
    }
    /*commented because we dont test VR on unit tests
	//Triggers' tests 
	@isTest
    static void CharCheckerForContactTriggerPositiveTest(){
        
    	Account acc = [Select Id From Account Limit 1];
						
		Test.startTest();          	
        	Boolean triggersError = false;
        	try{
        		Contact cont = TestFactory.newContact(acc.Id);
        		insert cont;
        		cont.MailingCity = 'Paris';
        		cont.MailingCountry = 'France';
        		update cont;
        	}catch(Exception e){
        		triggersError = true;	
        	}
      
        Test.stopTest();
		
		//asserts
		system.assertEquals(false,triggersError);					
	} */
	
	/************************/
	//Triggers' tests
	@isTest
    static void CharCheckerForContactTriggerNegativeTest(){
        
    	Account acc = [Select Id From Account Limit 1];
						
		Test.startTest();          	
        	Boolean triggersError = false;
        	try{
        		Contact cont = TestFactory.newContact(acc.Id,'雾非雾发','FirstName','Mr.','email@gmail.com');
        		insert cont;
        		cont.MailingCity = 'Paris';
        		cont.MailingCountry = 'France';
        		cont.FirstName = '雾非雾发';
        		update cont;
        	}catch(Exception e){
        		triggersError = true;	
        	}
      
        Test.stopTest();
		
		//asserts
		system.assertEquals(true,triggersError);					
	}
    
    public testmethod static void calculateGamification(){      

        test.startTest();
        
        Account acc = [Select Id From Account Limit 1];
        Contact result = LC02_gamificationController.getContactInfos(System.UserInfo.getUserId());
        Contact cont = TestFactory.newContact(acc.Id,'Last','FirstName','Mr.','email@gmail.com');
        insert cont;
        
        List<Badge__c> b = [select id, Badge_family__c,Name, Points_to_win__c,	Points_By_Action__c,Image__c , Image_url__c from Badge__c where Name =: AP00_UtilityConstants.BADGE_CONTACT_CREATION];
        if(b.size()>0){
            
        	List<User_badge__c> ubToEditlist = [select id, Badge__c , won_points__c ,Badge__r.Name, Badge__r.Badge_family__c,Badge__r.Points_to_win__c,	Badge__r.Points_By_Action__c from User_badge__c where Badge__c =:b[0].id  and contact__c =: result.Id];            
	
        	System.assert(ubToEditlist.size()>0 && ubToEditlist[0].won_points__c == 5,ubToEditlist);
        }
        
        test.stopTest();
        
    }
}