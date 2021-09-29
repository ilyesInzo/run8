@isTest
public class BA01_CountObjectifAccount_Schedule_Test {

    @isTest
    public static void testschedule(){
    	Test.StartTest();
		
        BA01_CountObjectifAccount_Schedule sh1 = new BA01_CountObjectifAccount_Schedule();

		String sch = '0 0 23 * * ?';
        system.schedule('Test scheduler', sch, sh1); 
        
        Test.stopTest();
    
    }
}