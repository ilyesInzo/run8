public class PMMoqPricesTriggerHandler extends TriggerHandler {

	private Map<Id,PM_MOQ_price__c> newPMMOQpricesById;
	
    public PMMoqPricesTriggerHandler() {
        this.newPMMOQpricesById = (Map<Id, PM_MOQ_price__c>) Trigger.newMap;
    	this.setMaxLoopCount(2);
   	}

   public override void afterUpdate() {
   		//Update the unique key for the records, used for upsertion in Price Matrix
   		PMMoqPricesService.setUniqueKey(newPMMOQpricesById.keyset());   			
   }

}