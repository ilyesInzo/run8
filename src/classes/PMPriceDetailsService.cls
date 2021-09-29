public with sharing class PMPriceDetailsService {
 	/**
     * @description setUniqueKey : set the unique key for the records, used for upsertion in Price Matrix
     * @param Set<Id> newPMPriceDetailsIds
     * @return void
     */
    public static void setUniqueKey(Set<Id> newPMPriceDetailsIds) {
    	List<PM_Price_Detail__c> liPPD = new List<PM_Price_Detail__c>();
		//Loop through the list of records and set the unique key
		for(PM_Price_Detail__c ppd :[select ExtId__c, Config_ID__c,Name, MOQ_Min__c, MOQ_Max__c
									from PM_Price_Detail__c 
									where id in :newPMPriceDetailsIds and ExtId__c =null]){
				ppd.ExtId__c = ppd.Config_ID__c+ppd.Name+(ppd.MOQ_Max__c== 999 ? 'Specific' : ''+integer.valueof(ppd.MOQ_Min__c)+'');  
				liPPD.add(ppd);				
		}
		update liPPD; 
    }//end setUniqueKey   
}