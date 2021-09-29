/**
* Test class of LC01_Review_DiscountComponentCtrl
*
* @author MDK
* @date 23/11/2017
* @description 
*
*/
@isTest
private class LC01_Review_DiscountComponentCtrlTest {

    @testSetup 
    private static void init() {
        insert new PM_Review_NetPrice_per_MOQ__c(Discount__c = 10);
    }
    
    @isTest
	private static void updateReviewPriceTest() {
        PM_Review_NetPrice_per_MOQ__c pmRevNetPperMoqBefore = [Select Discount__c From PM_Review_NetPrice_per_MOQ__c Limit 1];
        LC01_Review_DiscountComponentController.updateReviewPrice(pmRevNetPperMoqBefore);
        PM_Review_NetPrice_per_MOQ__c pmRevNetPperMoqAfter = [Select Discount__c From PM_Review_NetPrice_per_MOQ__c Limit 1];
        System.assertEquals(1, pmRevNetPperMoqAfter.Discount__c);        
    }
}