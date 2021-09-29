@istest public class AP00_UtilityConstants_Test {
 
    static TestMethod void AP00_UtilityConstants_UnitTest1(){
        Test.startTest();
			System.assertEquals(AP00_UtilityConstants.BADGE_ACCOUNT_CREATION,'Account Creation');
        System.assertEquals(AP00_UtilityConstants.BADGE_OPPORTUNITY_CREATION,'Opportunity Creation');
        System.assertEquals(AP00_UtilityConstants.BADGE_CONTACT_CREATION,'Contact Creation');
        System.assertEquals(AP00_UtilityConstants.BADGE_CONTACT_UPDATE,'Contact Update');
        System.assertEquals(AP00_UtilityConstants.BADGE_QUOTE_COPY,'Copy Quote');
        System.assertEquals(AP00_UtilityConstants.BADGE_LEAD_CONVERSION,'Lead Conversion');
        System.assertEquals(AP00_UtilityConstants.BADGE_LEAD_CREATION,'Lead Creation');
        System.assertEquals(AP00_UtilityConstants.BADGE_LEAD_UPDATE,'Lead Update');
        System.assertEquals(AP00_UtilityConstants.BADGE_EVENT_CREATION,'Event Creation');
        System.assertEquals(AP00_UtilityConstants.BADGE_TASK_CREATION,'Task Creation');
         System.assertEquals(AP00_UtilityConstants.BADGE_LOG_CALL , 'Call Log');
        System.assertEquals(AP00_UtilityConstants.BADGE_CHATTER_POST_COMMENT , 'Chatter Comments Posts'); 
        System.assertEquals(AP00_UtilityConstants.CONTACT_CONTACT_TYPE_USER , 'User'); 
        System.assertEquals(AP00_UtilityConstants.ACCOUNT_GAMIFICATION_ACCOUNT_NAME , 'GAMEACCOUNT'); 
        System.assertEquals(AP00_UtilityConstants.FINEMIST_PRODUCTSEGMENT_NAME , 'Fine mist pumps'); 
        
			test.stopTest();
    }

}