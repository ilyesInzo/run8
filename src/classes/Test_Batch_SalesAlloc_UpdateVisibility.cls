@isTest
public class Test_Batch_SalesAlloc_UpdateVisibility {

    static testmethod void test_Schedulable() {

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