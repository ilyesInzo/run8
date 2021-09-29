@isTest
public class LC03_displayAccountFields_TEST {

    public testmethod static void editDateHeliosCallTest(){
        
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
            
            //Create Test Accounts
            Account acc = TestFactory.newAccount(countries[0].Id,distCountry1.Id,salesArea.Id, state.Id, 'VAT1');
        	acc.Tech_dateOfTheLastHeliosCall__c = datetime.now().addMinutes(-10);
            insert acc;
        
        	test.startTest();
        
        	LC03_displayAccountFields.editDateHeliosCall(acc.id);
        
        	List<Account> result = [select id, Name, Tech_dateOfTheLastHeliosCall__c from Account where id =:acc.id ];
        
        	System.assert(result.size()>0 && result[0].Tech_dateOfTheLastHeliosCall__c > datetime.now().addMinutes(-10));
        	
        	test.stopTest();
	        
        
    }
    
    
}