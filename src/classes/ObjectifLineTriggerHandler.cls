public class ObjectifLineTriggerHandler extends TriggerHandler{
   
    private Map<Id,Objective_Lines__c> oldObjectifLinesById;
    private Map<Id,Objective_Lines__c> newObjectifLinesById;
    private List<Objective_Lines__c> newObjectifLines; 
    private List<Objective_Lines__c> oldObjectifLines;

    public ObjectifLineTriggerHandler() {
        this.oldObjectifLinesById = (Map<Id, Objective_Lines__c>) Trigger.oldMap;
        this.newObjectifLinesById = (Map<Id, Objective_Lines__c>) Trigger.newMap;
        this.newObjectifLines = (List<Objective_Lines__c>) Trigger.new;
        this.oldObjectifLines = (List<Objective_Lines__c>) Trigger.old; 
    }
 
    public override void beforeInsert() {
        ObjectifLineService.addObjectifKam(newObjectifLines);
    }
    
    
}