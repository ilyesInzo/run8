/**
* @description PM Dispensing Princing handler
* @author Malha A.
* @date 20/01/2019
*/

public class PMDispensingPricingHandler extends TriggerHandler{
    private Map<Id,PM_Dispensing_Pricing__c> oldPMPricingById;
    private Map<Id,PM_Dispensing_Pricing__c> newPMPricingById;
    private List<PM_Dispensing_Pricing__c> newPMPricing;
    private List<PM_Dispensing_Pricing__c> oldPMPricing;

    /**
     * @description Default constructor
     */
    public PMDispensingPricingHandler() {
        this.oldPMPricingById = (Map<Id, PM_Dispensing_Pricing__c>) Trigger.oldMap;
        this.newPMPricingById = (Map<Id, PM_Dispensing_Pricing__c>) Trigger.newMap;
        this.newPMPricing = (List<PM_Dispensing_Pricing__c>) Trigger.new;
        this.oldPMPricing = (List<PM_Dispensing_Pricing__c>) Trigger.old;
    }

     /**
     * @description beforeInsert on PM Dispensing Pricing Trigger
     * @return nothing
     */
    public override void beforeInsert() {

        PMPricingService.checkDates(newPMPricing, 'PM_Dispensing_Pricing__c', new list<String> {
                                                                                                 'Ref__c',
                                                                                                 'Location__c' 
                                                                                                 
                                                                                                });
    }


}