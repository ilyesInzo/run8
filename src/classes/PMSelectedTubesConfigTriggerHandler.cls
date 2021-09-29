public with sharing class PMSelectedTubesConfigTriggerHandler extends TriggerHandler {
   
    private Map<Id,PM_Selected_Tubes_Config__c> oldPMSelectedTubesConfigsById;
    private Map<Id,PM_Selected_Tubes_Config__c> newPMSelectedTubesConfigsById;
    private List<PM_Selected_Tubes_Config__c> newPMSelectedTubesConfigs; 
    private List<PM_Selected_Tubes_Config__c> oldPMSelectedTubesConfigs;

    public PMSelectedTubesConfigTriggerHandler() {
        this.oldPMSelectedTubesConfigsById = (Map<Id, PM_Selected_Tubes_Config__c>) Trigger.oldMap;
        this.newPMSelectedTubesConfigsById = (Map<Id, PM_Selected_Tubes_Config__c>) Trigger.newMap;
        this.newPMSelectedTubesConfigs = (List<PM_Selected_Tubes_Config__c>) Trigger.new;
        this.oldPMSelectedTubesConfigs = (List<PM_Selected_Tubes_Config__c>) Trigger.old; 
    }

    public override void beforeUpdate() {
            newPMSelectedTubesConfigs[0].Is_from_preconfig__c = false;
    }
        
    public override void afterUpdate() {    	
		//Calculate the PM Prices and MOQ Prices based on the config
        PMCalculatorUtility.handleCalculator((PM_Selected_Tubes_Config__c) newPMSelectedTubesConfigs[0]);
        
        // Copy data from Selected Tubes config to QuoteItem (needed for QUOTE PDF template )
       // PM_SelectedTubesConfigHelper.copyDataToQuoteItem(Trigger.new);
        PMSelectedTubesConfigService.copyDataToQuoteItemVer2(newPMSelectedTubesConfigs);      
        system.debug('@@qama newPMSelectedTubesConfigs[0].ID '+newPMSelectedTubesConfigs[0].ID);
        PM_Selected_Tubes_Config__c testSelConfig = newPMSelectedTubesConfigs[0];
        list<PM_Review_NetPrice_per_MOQ__c> liPMReviewsToUpdate = new list<PM_Review_NetPrice_per_MOQ__c>();
        for(PM_Review_NetPrice_per_MOQ__c fp : [select id, Tech_Update_is_from_AdjustNetPrice__c from PM_Review_NetPrice_per_MOQ__c 
                                                 where Quote_Line_Item__c = :testSelConfig.Quote_item__c
                                                limit 7]){
			fp.Tech_Update_is_from_AdjustNetPrice__c = false;
			liPMReviewsToUpdate.add(fp);
		}
		system.debug('@@qama liPMReviewsToUpdate '+liPMReviewsToUpdate);
		update liPMReviewsToUpdate;
        
        //reset Tech_Update_is_from_AdjustNetPrice__c on related final prices(section 6) == BREXIT
      	/*list<string> liIDs = new list<string>();
        set<string> setIDs = new set<string>();
        for(string fpID: newPMSelectedTubesConfigsById.keyset()){
            if(fpID != null)
            	setIDs.add(fpID);
        }
        liIDs.addAll(setIDs);
        list<PM_Review_NetPrice_per_MOQ__c> liPMReviewsToUpdate = new list<PM_Review_NetPrice_per_MOQ__c>();
         for(PM_Review_NetPrice_per_MOQ__c fp : [select id, Tech_Update_is_from_AdjustNetPrice__c from PM_Review_NetPrice_per_MOQ__c where ID_Selected_Config__c in :liIDs]){
			fp.Tech_Update_is_from_AdjustNetPrice__c = false;
			liPMReviewsToUpdate.add(fp);
		}
		system.debug('@@qama liPMReviewsToUpdate '+liPMReviewsToUpdate);
		update liPMReviewsToUpdate;*/
    }

    public override void afterInsert() {        
    	//Calculate the PM Prices and MOQ Prices based on the config
     //   PMCalculatorUtility.handleCalculator((PM_Selected_Tubes_Config__c) newPMSelectedTubesConfigs[0]); //commented by maryem QADA : because no need to do calculation at insert
                
        // Copy data from Selected Tubes config to QuoteItem (needed for QUOTE PDF template )
       // PM_SelectedTubesConfigHelper.copyDataToQuoteItem(Trigger.new);
		
        //New Version for Quote Copy
        PMSelectedTubesConfigService.copyDataToQuoteItemVer2(newPMSelectedTubesConfigs);  
        
    }
    
    public override void beforeInsert() {    
    	//prefill values of Platts and CDI
    	PMSelectedTubesConfigService.fillResinIndexValues(newPMSelectedTubesConfigs)	; 
    }
}