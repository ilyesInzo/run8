@isTest 
public with sharing class SCH_scheduledBatch_TEST {
    public static testMethod void testschedule() {
		Test.StartTest();
			
			SCH_scheduledBatchable sh1 = new SCH_scheduledBatchable();
			String sch = '0 0 * * * ?'; 
			String jobId = system.schedule('Test SCH_scheduledBatch_objective', sch, sh1);
    	Test.stoptest();
    	
    	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,  NextFireTime  
         					FROM CronTrigger 
         					WHERE id = :jobId]; 
 
      System.assertNotEquals(ct, null);
	}

}