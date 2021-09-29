/**
* @description Service class for interacting with PMReviewNetPriceperMoq
* @author MQ
* @date 29/11/2017
*/ 
public class PMSelectedDipsensingconfigTriggerHandler extends TriggerHandler {
	
	private Map<Id,PM_Selected_Dipsensing_config__c> oldPMSelectedDipsensingconfigById;
    private Map<Id,PM_Selected_Dipsensing_config__c> newPMSelectedDipsensingconfigById;
    private List<PM_Selected_Dipsensing_config__c> newPMSelectedDipsensingconfigs; 
    private List<PM_Selected_Dipsensing_config__c> oldPMSelectedDipsensingconfigs;

    public PMSelectedDipsensingconfigTriggerHandler() {
        this.oldPMSelectedDipsensingconfigById = (Map<Id, PM_Selected_Dipsensing_config__c>) Trigger.oldMap;
        this.newPMSelectedDipsensingconfigById = (Map<Id, PM_Selected_Dipsensing_config__c>) Trigger.newMap;
        this.newPMSelectedDipsensingconfigs = (List<PM_Selected_Dipsensing_config__c>) Trigger.new;
        this.oldPMSelectedDipsensingconfigs = (List<PM_Selected_Dipsensing_config__c>) Trigger.old; 
    }
          
    public override void beforeUpdate() {
        newPMSelectedDipsensingconfigs[0].Is_from_preconfig__c = false;
		if(newPMSelectedDipsensingconfigs[0].Product_Segment__c == 'Lotion pumps' && newPMSelectedDipsensingconfigs[0].Location__c == 'EU'){

            AP00_LotionLeadTime.calcLotionLeadTime(newPMSelectedDipsensingconfigs[0]);
        }
              
    }

    public override void afterUpdate() {
    		PMCalculatorUtility.handleCalculatorDispensing((PM_Selected_Dipsensing_config__c)newPMSelectedDipsensingconfigs[0]);
        	PMSelectedDipsensingconfigService.copyDataToQuoteItemVer2(newPMSelectedDipsensingconfigs);	
    }
    
    public override void afterInsert() {
    		PMCalculatorUtility.handleCalculatorDispensing((PM_Selected_Dipsensing_config__c)newPMSelectedDipsensingconfigs[0]);
    		PMSelectedDipsensingconfigService.copyDataToQuoteItemVer2(newPMSelectedDipsensingconfigs);   	
    }
    
    public override void beforeInsert() {
    	//LeadTime Calc
        	if(newPMSelectedDipsensingconfigs[0].Product_Segment__c == 'Lotion pumps' && newPMSelectedDipsensingconfigs[0].Location__c == 'EU'){
            	AP00_LotionLeadTime.calcLotionLeadTime(newPMSelectedDipsensingconfigs[0]);
        }
    }
}