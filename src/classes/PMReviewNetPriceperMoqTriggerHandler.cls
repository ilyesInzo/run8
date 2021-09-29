public without sharing class PMReviewNetPriceperMoqTriggerHandler extends TriggerHandler {
	
	private Map<Id,PM_Review_NetPrice_per_MOQ__c> oldPMReviewNetPriceperMoqById;
    private Map<Id,PM_Review_NetPrice_per_MOQ__c> newPMReviewNetPriceperMoqById;
    private List<PM_Review_NetPrice_per_MOQ__c> newPMReviewNetPriceperMoqs; 
    private List<PM_Review_NetPrice_per_MOQ__c> oldPMReviewNetPriceperMoqs;

    public PMReviewNetPriceperMoqTriggerHandler() {
        this.oldPMReviewNetPriceperMoqById = (Map<Id, PM_Review_NetPrice_per_MOQ__c>) Trigger.oldMap;
        this.newPMReviewNetPriceperMoqById = (Map<Id, PM_Review_NetPrice_per_MOQ__c>) Trigger.newMap;
        this.newPMReviewNetPriceperMoqs = (List<PM_Review_NetPrice_per_MOQ__c>) Trigger.new;
        this.oldPMReviewNetPriceperMoqs = (List<PM_Review_NetPrice_per_MOQ__c>) Trigger.old; 
    }
         
    public override void beforeUpdate() {
    
    }

    public override void afterUpdate() {
    	//PMReviewNetPriceperMoqService.updateRelatedQuotelineitem(newPMReviewNetPriceperMoqs);    
    	PMReviewNetPriceperMoqService.updateRelatedQuotelineitem_BULK(newPMReviewNetPriceperMoqs);  
    }
    
}