@isTest 
public with sharing class Batch_SalesAlloc_VisibilitySchdlTest {
public static testMethod void testschedule() {
    	
		Test.StartTest();
			Batch_SalesAlloc_UpdateVisibility_Schdl sh1 = new Batch_SalesAlloc_UpdateVisibility_Schdl();
			String sch = '0 0 0 * * ?'; 
			String jobId = system.schedule('Test Batch_SalesAlloc_UpdateVisibility_Schdl', sch, sh1);   
		
    	Test.stoptest();    	
    	
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,  NextFireTime  
         					FROM CronTrigger 
         					WHERE id = :jobId]; 
 
      System.assertNotEquals(ct, null); 
    	
    }
}