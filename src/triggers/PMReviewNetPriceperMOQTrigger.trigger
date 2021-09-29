trigger PMReviewNetPriceperMOQTrigger on PM_Review_NetPrice_per_MOQ__c (after update, before update) {
	new PMReviewNetPriceperMoqTriggerHandler().run();    
}