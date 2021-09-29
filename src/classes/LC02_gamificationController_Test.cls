/**
 * description : Test Class of LC02_gamificationController Class
 * @author Achraf LAMZABI
 * @version 1.0 - Initiale
 */
@isTest
public class LC02_gamificationController_Test {
    
    
    @testSetup 
    private static void init() {
        		
        		//Create Country
        		Country__c frCountry = TestFactory.getFrance();
            	insert frCountry;
    
                //Create Distribution Channel
                Distribution_Channel__c distCountry1 = TestFactory.newDistributionChannel();
                insert distCountry1;
                
                //Create Sales Area
                Sales_Area__c salesArea = TestFactory.newSalesArea();
                insert salesArea;
    
                // Create a State
                State__c state = TestFactory.newState('FRANCE','FR');
            	state.Country__c = frCountry.id;
                insert state;
                
                //Create Test Accounts
    
                Account acc = TestFactory.newAccount(frCountry.Id,distCountry1.Id,salesArea.Id, state.Id,'VAT1');
            	acc.Street__c = 'Cartault';
        		acc.Name = AP00_UtilityConstants.ACCOUNT_GAMIFICATION_ACCOUNT_NAME;
                insert acc; 

    }

    
     
    public testmethod static void getContactInfos1(){      
        

        test.startTest();
        Contact result = LC02_gamificationController.getContactInfos(System.UserInfo.getUserId());
        System.assert(result != null , result);
        
        test.stopTest();
        
    }
    
     public testmethod static void getContactInfos2(){      
        
		Account acc = [select id , Name from Account where Name =: AP00_UtilityConstants.ACCOUNT_GAMIFICATION_ACCOUNT_NAME limit 1];
        delete acc;
        test.startTest();
        Contact result = LC02_gamificationController.getContactInfos(System.UserInfo.getUserId());
        System.assert(result == null , result);
        
        test.stopTest();
        
    }
    
    
    
    
    
    
    
}