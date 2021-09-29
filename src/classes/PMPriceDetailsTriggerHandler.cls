public class PMPriceDetailsTriggerHandler extends TriggerHandler{

    private Map<Id,PM_Price_Detail__c> newPMPriceDetailsById;
    
	public PMPriceDetailsTriggerHandler() {
        this.newPMPriceDetailsById = (Map<Id, PM_Price_Detail__c>) Trigger.newMap;        
    	this.setMaxLoopCount(2);
   	}

   public override void afterUpdate() {
   		//set the unique key for the records, used for upsertion in Price Matrix
   		PMPriceDetailsService.setUniqueKey(newPMPriceDetailsById.keyset());
   	}
}