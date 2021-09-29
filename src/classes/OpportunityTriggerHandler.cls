public class OpportunityTriggerHandler extends TriggerHandler {
   
    private Map<Id,Opportunity> oldOpportunitiesById;
    private Map<Id,Opportunity> newOpportunitiesById;
    private List<Opportunity> newOpportunities; 
    private List<Opportunity> oldOpportunities;

    public OpportunityTriggerHandler() {
        this.oldOpportunitiesById = (Map<Id, Opportunity>) Trigger.oldMap;
        this.newOpportunitiesById = (Map<Id, Opportunity>) Trigger.newMap;
        this.newOpportunities = (List<Opportunity>) Trigger.new;
        this.oldOpportunities = (List<Opportunity>) Trigger.old; 
    }

   	public override void beforeUpdate() {
		OpportunityService.checkEditSimulationStatus(newOpportunities,oldOpportunitiesById);
   		SObjectUtils.checkChar(newOpportunities); 	    
    }
 
    public override void beforeInsert() {
    	SObjectUtils.checkChar(newOpportunities);    
    }
    
    public override void afterInsert() {
        LC02_CalculateGamificationPoints.calculatePoints(AP00_UtilityConstants.BADGE_OPPORTUNITY_CREATION);
        
    }

}