public class LeadTriggerHandler extends TriggerHandler {
   
    private Map<Id,Lead> oldLeadsById;
    private Map<Id,Lead> newLeadsById;
    private List<Lead> newLeads; 
    private List<Lead> oldLeads;

    public LeadTriggerHandler() {
        this.oldLeadsById = (Map<Id, Lead>) Trigger.oldMap;
        this.newLeadsById = (Map<Id, Lead>) Trigger.newMap;
        this.newLeads = (List<Lead>) Trigger.new;
        this.oldLeads = (List<Lead>) Trigger.old; 
    }
        
    public override void beforeUpdate() {
        
        if(newLeads.size()>0){
            System.debug('NewLead1 :' + newLeads[0]);
        	System.debug('OldLead1 :' + oldLeadsById.get(newLeads[0].id));
        }
        if(newLeads.size()>1){
            System.debug('NewLead2 :' + newLeads[1]);
        	System.debug('OldLead2 :' + oldLeadsById.get(newLeads[1].id));
        }
        if(newLeads.size()>2){
            System.debug('NewLead3 :' + newLeads[2]);
        	System.debug('OldLead3 :' + oldLeadsById.get(newLeads[2].id));
        }
        
        
   		SObjectUtils.checkChar(newLeads);
        LeadService.fillProductLineForWebsiteSource(newLeads);
    }
  
    public override void beforeInsert() {
        LeadService.fillCountryLoockup(newLeads);
        LeadService.fillProductLineForWebsiteSource(newLeads);
    	SObjectUtils.checkChar(newLeads);
        
    }
    
    public override void afterInsert() {
    	LeadService.getInstance().assignForWebSite(newLeads);
        LC02_CalculateGamificationPoints.calculatePoints(AP00_UtilityConstants.BADGE_LEAD_CREATION);
    }
	
    public override void afterUpdate() {
        
        LeadService.GameCalculationConvertedLead(newLeads,oldLeadsById);
    }
    
}