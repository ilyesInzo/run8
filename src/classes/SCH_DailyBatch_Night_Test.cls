@isTest 
public with sharing class SCH_DailyBatch_Night_Test {
 
    public static testMethod void testschedule() {
    	
		Test.StartTest();
			SCH_DailyBatch_Night sh1 = new SCH_DailyBatch_Night();
			String sch = '0 0 0 * * ?'; 
			String jobId = system.schedule('Test SCH_DailyBatch_Night', sch, sh1);   
		
    	Test.stoptest();    	
    	
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,  NextFireTime  
         					FROM CronTrigger 
         					WHERE id = :jobId]; 
 
      System.assertNotEquals(ct, null); 
    	
    }
}