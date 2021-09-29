public class PlantSegmentUsersTriggerHandler extends TriggerHandler {
    
    private Map<Id,Plant_Segment_Users__c> oldPlantSegmentUsersById;
    private Map<Id,Plant_Segment_Users__c> newPlantSegmentUsersById;
    private List<Plant_Segment_Users__c> newPlantSegmentUsers;
    private List<Plant_Segment_Users__c> oldPlantSegmentUsers;

    /**
     * @description Default constructor
     */
    public PlantSegmentUsersTriggerHandler() {
        this.oldPlantSegmentUsersById = (Map<Id, Plant_Segment_Users__c>) Trigger.oldMap;
        this.newPlantSegmentUsersById = (Map<Id, Plant_Segment_Users__c>) Trigger.newMap;
        this.newPlantSegmentUsers = (List<Plant_Segment_Users__c>) Trigger.new;
        this.oldPlantSegmentUsers = (List<Plant_Segment_Users__c>) Trigger.old;
    }

    /**
     * @description afterDelete on Plant_Segment_Users__c Trigger
     * @return nothing
     */
    public override void afterDelete() {

        PlantSegmentService.updateAccOppTeam(oldPlantSegmentUsers);
   
    }
    
    
    /**
     * @description afterInsert on Plant_Segment_Users__c Trigger
     * 
     */
    public override void afterInsert() {

        PlantSegmentService.PlantUserSegAccOppTeam(newPlantSegmentUsers);
   
    }
    
}