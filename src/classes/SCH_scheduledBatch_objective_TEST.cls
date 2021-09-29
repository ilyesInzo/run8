@isTest 
public with sharing class SCH_scheduledBatch_objective_TEST {
	
	public static testMethod void testschedule() {
		Test.StartTest();
			
			SCH_scheduledBatch_objective sh1 = new SCH_scheduledBatch_objective();
			String sch = '0 0 * * * ?'; 
			String jobId = system.schedule('Test SCH_scheduledBatch_objective', sch, sh1);
    	Test.stoptest();
    	
    	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,  NextFireTime  
         					FROM CronTrigger 
         					WHERE id = :jobId]; 
 
      System.assertNotEquals(ct, null);
	}
    
}