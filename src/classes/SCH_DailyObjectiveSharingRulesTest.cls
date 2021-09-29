@isTest 
public class SCH_DailyObjectiveSharingRulesTest {
 public static testMethod void testschedule() {
    	
		Test.StartTest();
			SCH_DailyObjectiveSharingRules sh1 = new SCH_DailyObjectiveSharingRules();
			String sch = '0 0 * * * ?'; 
			String jobId = system.schedule('Test SCH_DailyObjectiveSharingRules', sch, sh1);   
		
    	Test.stoptest();    	
    	
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,  NextFireTime  
         					FROM CronTrigger 
         					WHERE id = :jobId]; 
 
      System.assertNotEquals(ct, null); 
    	
    }
}