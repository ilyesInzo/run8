/**
* Test class of ContractService
*
* @author MDK
* @date 09/10/2017
* @description The aim of this class is to test :
*    - all ContractService methods
*   
*/
@isTest
private class ContractServiceTest {

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
        insert acc1;  
    }

	@isTest
	private static void alertContractTest(){

		//Select Account
		Account acc = [Select Id From Account Limit 1];
        
        Contact con = TestFactory.newContact(acc.Id);
        insert con;
        
        Contract contract1 = new Contract(
	        AccountId = acc.Id,
	        StartDate = Date.newInstance(date.today().year(),date.today().month() - 6,date.today().Day()),
	        Status = 'Draft',
	        ContractTerm = 36,
	        CustomerSignedId = con.Id
        );
        insert contract1;
        
        
        Contract contract2 = new Contract(
	        AccountId = acc.Id,
	        StartDate = Date.newInstance(date.today().year(),date.today().month() - 12,date.today().Day()),
	        Status = 'Draft',
	        ContractTerm = 36,
	        CustomerSignedId = con.Id
        );
        insert contract2;        
        
        Test.startTest();    
            //Run and test the batch
            BA01_Contract_Reminder batch = new BA01_Contract_Reminder();
            batch = new BA01_Contract_Reminder('Select Id, CustomerSigned.Id, StartDate, EndDate from Contract Where CustomerSignedId != null');
            try {
                Database.executeBatch(batch);    
            } catch (DmlException e) {
                
            }   

            //EmailMessage email = [Select FromAddress,ParentId From EmailMessage Limit 1];
            //System.assertEquals(con.Id,email.ParentId);
                     
            // Test the scheduler
            SCH_WeeklyBatch scheduler = new SCH_WeeklyBatch();
            String cron = '0 0 * * * ?'; 
            String jobId = System.schedule('Test SCH_HourlyBatch', cron, scheduler);   
        
            CronTrigger ct = [
                Select 
                    Id, 
                    CronExpression, 
                    TimesTriggered,  
                    NextFireTime  
                From CronTrigger 
                Where id = :jobId
            ]; 
 
            System.assertNotEquals(ct, null);

        Test.stopTest();


        
        
    }
}