public class LC01_Review_DiscountComponentController {
    
    @AuraEnabled
    public static void updateReviewPrice(PM_Review_NetPrice_per_MOQ__c reviewPriceDetail){
    
    	system.debug('--- reviewPriceDetail ---'+reviewPriceDetail);
        reviewPriceDetail.Discount__c = reviewPriceDetail.Discount__c/10;
        system.debug('--- reviewPriceDetail ---'+reviewPriceDetail);
        update reviewPriceDetail; 
    
    }

}