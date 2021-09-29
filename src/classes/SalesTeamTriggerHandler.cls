/**
* Trigger Handler for Sales_Team__c object
*
* @author MDK
* @date 09/10/2017
* @description
*
*/
public with sharing class SalesTeamTriggerHandler extends TriggerHandler {
   
	private Map<Id,Sales_Team__c> oldSalesTeamsById;
	private Map<Id,Sales_Team__c> newSalesTeamsById;
	private List<Sales_Team__c> newSalesTeams;
	private List<Sales_Team__c> oldSalesTeams;

	public SalesTeamTriggerHandler() {
	    this.oldSalesTeamsById = (Map<Id, Sales_Team__c>) Trigger.oldMap;
	    this.newSalesTeamsById = (Map<Id, Sales_Team__c>) Trigger.newMap;
	    this.newSalesTeams = (List<Sales_Team__c>) Trigger.new;
	    this.oldSalesTeams = (List<Sales_Team__c>) Trigger.old;
	}

	public override void beforeUpdate() {
		SalesTeamService.getInstance().updateSalesTeam(newSalesTeams,oldSalesTeamsById);	
		SalesTeamService.getInstance().updateRequestForSalesTeams(newSalesTeams,oldSalesTeamsById);

	}	

	public override void afterUpdate() {


		// The update will be done only when new and old Sales Teams will change, when the Sales Team is not cloned and Sales Allocations
		// are not archived (for example when a Sales Team is updated twice the same day)
		TriggerHandler.bypass('OpportunityTriggerHandler');
		OpportunityService.getInstance().updateOpptyOwnerId(newSalesTeams,oldSalesTeamsById);		
		TriggerHandler.clearBypass('OpportunityTriggerHandler');

		SalesTeamService.getInstance().afterUpdateSalesTeam(newSalesTeamsById);
       // SalesTeamService.getInstance().updateSalesTeamsVisibility(newSalesTeams, oldSalesTeamsById, false);

	}

	public override void beforeInsert() {
		//SalesTeamService.getInstance().updateRequestForSalesTeams(newSalesTeams,oldSalesTeamsById);
	}

	public override  void afterInsert(){
		//SalesTeamService.getInstance().updateSalesTeamsVisibility(newSalesTeams, oldSalesTeamsById, true);
	}




}