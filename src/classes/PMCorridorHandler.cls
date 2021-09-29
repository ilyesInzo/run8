/**
* @description PM Corridor Handler
* @author Malha A.
* @date 21/01/2019
*/


public class PMCorridorHandler extends TriggerHandler{
    private Map<Id,PM_Discount_corridor__c> oldPMCorridorById;
    private Map<Id,PM_Discount_corridor__c> newPMCorridorById;
    private List<PM_Discount_corridor__c> newPMCorridor;
    private List<PM_Discount_corridor__c> oldPMCorridor;

    /**
     * @description Default constructor
     */
    public PMCorridorHandler() {
        this.oldPMCorridorById = (Map<Id, PM_Discount_corridor__c>) Trigger.oldMap;
        this.newPMCorridorById = (Map<Id, PM_Discount_corridor__c>) Trigger.newMap;
        this.newPMCorridor = (List<PM_Discount_corridor__c>) Trigger.new;
        this.oldPMCorridor = (List<PM_Discount_corridor__c>) Trigger.old;
    }

     /**
     * @description beforeInsert on PM Corridor  Trigger
     * @return nothing
     */
    public override void beforeInsert() {

        PMPricingService.checkDates(newPMCorridor, 'PM_Discount_corridor__c', new list<String> {
                                                                                                 'Peer_Group__c',
                                                                                                 'Location__c', 
                                                                                                 'Peer_Group_Name__c'
                                                                                                });
    }


}