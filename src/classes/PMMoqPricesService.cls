public with sharing class PMMoqPricesService {
	/**
     * @description setUniqueKey : set the unique key for the records, used for upsertion in Price Matrix
     * @param Map<Id,PM_MOQ_price__c>
     * @return void
     */
    public static void setUniqueKey(Set<Id> newPMMOQpricesIds) {
    	List<PM_MOQ_price__c> liPMPToUpdate = new List<PM_MOQ_price__c>();
    	//Loop through the list of records and set the unique key
		for(PM_MOQ_price__c pmp : [select ExtId__c,MOQ_Min__c,Config_ID__c , MOQ_Max__c 
									from PM_MOQ_price__c 
									where id in :newPMMOQpricesIds and ExtId__c =null]){
			pmp.ExtId__c = (pmp.MOQ_Max__c== 999 ? ''+pmp.MOQ_Max__c+'' : ''+pmp.MOQ_Min__c+'') +'-'+pmp.Config_ID__c;	 
			liPMPToUpdate.add(pmp);
		}
		update liPMPToUpdate;	
    
    }//end setUniqueKey
    
}