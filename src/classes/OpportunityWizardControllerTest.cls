@isTest 
public class OpportunityWizardControllerTest {
    public static testmethod void testOpportunityWizard(){
        
        //Create Test Data
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
        insert acc;
        
        //Account acc2 = new Account(Name = 'Acc 2 de test'+datetime.now(), Country__c = country.Id ,Distribution_Channel__c=testDistrib.id,Sales_Area__c=testArea.id,Account_status__c='Active',Type='Client');
        Account acc2 = TestFactory.newAccount(country, testDistrib, testArea);
        insert acc2;
        
        
        //Create Test Users for the Teams
        List<User> users = new List<User>();
        String pid = [Select id from Profile where Name='System Administrator'].Id; 
        
        //Retrieve KAM PRofile
        Profile KAM = [select id,Name from Profile where Name ='SALES - KAM' limit 1];
        
        
        for(integer i=1; i<=10; i++){
            String orgId = 'Albea';
            
            User tuser = new User(  firstname = 'test',
                                  lastName = 'user'+i,
                                  email = 'test_user'+i+ '@test' + orgId + '.com',
                                  Username = 'test_user'+i+ '@test' + orgId + '.com',
                                  EmailEncodingKey = 'ISO-8859-1',
                                  Alias = 'test'+i,
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  LocaleSidKey = 'en_US',
                                  LanguageLocaleKey = 'en_US',
                                  Additional__c = true,
                                  Director__c = true,
                                  KAM__c = true,
                                  Matricule_ADS__c = string.valueof(i+1000),
                                  Manager__c = true,
                                  ProfileId = KAM.id);
            users.add(tuser);                               
        }
        
        users[4].ProfileId = KAM.id;
        insert users;
        
        
        //Create Test Sales Teams
        Sales_Team__c team1 = new Sales_Team__c();
        team1.KAM__c = users[0].id;
        team1.Manager__c = users[1].id;
        team1.Director__c = users[2].id;
        team1.Additional__c = users[3].id;
        team1.Valid_From__c = Date.today().addYears(-1);
        team1.Valid_To__c = Date.today().addYears(3);
        team1.Sales_Team__c = 'test team 1';
        team1.Sales_Team__c = '1111';
        
        insert team1;
        
        Sales_Team__c team2 = new Sales_Team__c();
        team2.KAM__c = users[4].id;
        team2.Manager__c = users[5].id;
        team2.Director__c = users[6].id;
        team2.Additional__c = users[7].id;
        team2.Valid_From__c = Date.today().addYears(-1);
        team2.Valid_To__c = Date.today().addYears(3);
        team2.Sales_Team__c = 'test team 2';
        team2.Sales_Team__c = '2222';
        insert team2;
        
        
        Opportunity opp1 = new Opportunity(Name = 'Test Opp 1', AccountId = acc.Id, StageName = 'Qualification', 
                                           CloseDate = Date.today(), Contract__c ='Yes', Duration_Y__c ='2');
        insert opp1;
        
        Opportunity opp2 = new Opportunity(Name = 'Test Opp 2', AccountId = acc.Id, StageName = 'Qualification', 
                                           CloseDate = Date.today(), Contract__c ='No');
        insert opp2;
        
        Map<String, object> result1 = OpportunityWizardController.getdisplayContractReminder(opp1.Id);
        Map<String, object> result2 = OpportunityWizardController.getdisplayContractReminder(opp2.Id);
        
        system.assertEquals(true, result1.get('displayContractReminder'));  
        system.assertEquals(false, result2.get('displayContractReminder'));
        
        Map<String, object> result3 = OpportunityWizardController.getdisplayContractReminder(opp1.Id);
        system.assertEquals(false, result3.get('displayContractReminder'));
        
    }
    
}