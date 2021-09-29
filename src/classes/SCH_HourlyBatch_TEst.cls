@isTest 
public with sharing class SCH_HourlyBatch_TEst {
	
    public static testMethod void testschedule() {
    	
		Test.StartTest();
			SCH_HourlyBatch sh1 = new SCH_HourlyBatch();
			String sch = '0 0 * * * ?'; 
			String jobId = system.schedule('Test SCH_HourlyBatch', sch, sh1);   
		
    	Test.stoptest();    	
    	
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,  NextFireTime  
         					FROM CronTrigger 
         					WHERE id = :jobId]; 
 
      System.assertNotEquals(ct, null); 
    	
    }
}