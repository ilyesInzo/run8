@isTest
public class BA01_CountObjectifAccount_Test {

    @isTest
    public static void updateNumberOfClient_TEST(){
    	
        // Create User For Test 
        User us = TestFactory.newUser('test','user','SALES - KAM', true, true, true, true, 123);
        insert us;
    	Country__c country = new Country__c(Name = 'France', Country_Code__c = 'FX');
        insert country;
        
        //Create Test Distribution Channel
        Distribution_Channel__c testDistrib = new Distribution_Channel__c(Name ='Test',Distribution_Channel_Code__c='test',Language_Key__c='test');
        insert testDistrib;
        
        //Create Sales Area
        Sales_Area__c testArea = new Sales_Area__c(Name='Test');
        insert testArea;
        
        //Create Test Accounts
        //Account acc = new Account(Name = 'Test Acc 1'+datetime.now(), Country__c = country.Id,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc = TestFactory.newAccount(country, testDistrib, testArea);
        acc.Customer_Ranking__c ='Gold';
        
        Account acc1 = TestFactory.newAccount(country, testDistrib, testArea);
        acc1.Customer_Ranking__c ='Platinum';
        
        Account acc2 = TestFactory.newAccount(country, testDistrib, testArea);
        acc2.Customer_Ranking__c ='Silver';
        
        Account acc3 = TestFactory.newAccount(country, testDistrib, testArea);
        acc3.Customer_Ranking__c ='Bronze';
        
        insert new List<Account>{acc,acc1,acc2,acc3};
            
        AccountTeamMember atm = new AccountTeamMember (AccountId = acc.id, UserId = us.id);
        AccountTeamMember atm1 = new AccountTeamMember (AccountId = acc1.id, UserId = us.id);
        AccountTeamMember atm2 = new AccountTeamMember (AccountId = acc2.id, UserId = us.id);
        AccountTeamMember atm3 = new AccountTeamMember (AccountId = acc3.id, UserId = us.id);
        
        insert new List<AccountTeamMember>{atm,atm1,atm2,atm3};
				
        KAM_Objectives__c kamObjectif = new KAM_Objectives__c(
        		Name = 'Test Objectif',
        		Year__c = '2020',
        		OwnerId = us.id );
        
        insert kamObjectif;
        
    	Objective_Lines__c objectifLine = new Objective_Lines__c(
        	Account__c = acc.id,
            Type_of_task__c = 'Call',
            KAM__c = us.id
        );
        
        insert objectifLine;
        
        test.startTest();
        
        BA01_CountObjectifAccount ba = new BA01_CountObjectifAccount();
        Database.executeBatch(ba);
        
        test.stopTest();
        
        List<KAM_Objectives__c> result = [select id, Name,Number_of_Gold_clients__c,Number_of_Platinum_clients__c,
                                          Number_of_Silver_clients__c,Number_of_Bronze_clients__c from KAM_Objectives__c 
                                          where id =: kamObjectif.id ];
        
		        
        System.assert(result.size()>0 && result[0].Number_of_Gold_clients__c ==1 &&
                     result[0].Number_of_Platinum_clients__c ==1 && result[0].Number_of_Silver_clients__c ==1 &&
                     result[0].Number_of_Bronze_clients__c ==1);
        
        
        
    }
    
}