public with sharing class PMSelectedServiceTubesConfigTriggHandler extends TriggerHandler {
   
    private Map<Id,PM_Selected_Service_Tubes_Config__c> oldPMSelectedServiceTubesConfigsById;
    private Map<Id,PM_Selected_Service_Tubes_Config__c> newPMSelectedServiceTubesConfigsById;
    private List<PM_Selected_Service_Tubes_Config__c> newPMSelectedServiceTubesConfigs; 
    private List<PM_Selected_Service_Tubes_Config__c> oldPMSelectedServiceTubesConfigs;

    public PMSelectedServiceTubesConfigTriggHandler() {
        this.oldPMSelectedServiceTubesConfigsById = (Map<Id, PM_Selected_Service_Tubes_Config__c>) Trigger.oldMap;
        this.newPMSelectedServiceTubesConfigsById = (Map<Id, PM_Selected_Service_Tubes_Config__c>) Trigger.newMap;
        this.newPMSelectedServiceTubesConfigs = (List<PM_Selected_Service_Tubes_Config__c>) Trigger.new;
        this.oldPMSelectedServiceTubesConfigs = (List<PM_Selected_Service_Tubes_Config__c>) Trigger.old; 
    }
        
    public override void beforeUpdate() {

        LC01_ServiceTubeConfigCtrl.calculateservicedetail(trigger.new, trigger.old);
        
    }
   
}