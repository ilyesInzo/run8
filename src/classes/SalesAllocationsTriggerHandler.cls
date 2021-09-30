/**
* Trigger Handler for Sales_Allocations__c object
*
* @author MDK
* @date 09/10/2017
* @description
*
*/
public class SalesAllocationsTriggerHandler extends TriggerHandler {
   
	private Map<Id,Sales_Allocations__c> oldSalesAllocationsById;
	private Map<Id,Sales_Allocations__c> newSalesAllocationsById;
	private List<Sales_Allocations__c> newSalesAllocations;
	private List<Sales_Allocations__c> oldSalesAllocations;

	public SalesAllocationsTriggerHandler() {
	    this.oldSalesAllocationsById = (Map<Id, Sales_Allocations__c>) Trigger.oldMap;
	    this.newSalesAllocationsById = (Map<Id, Sales_Allocations__c>) Trigger.newMap;
	    this.newSalesAllocations = (List<Sales_Allocations__c>) Trigger.new;
	    this.oldSalesAllocations = (List<Sales_Allocations__c>) Trigger.old;
	}

	public override void beforeInsert() {
		SalesAllocationsService.getInstance().setSalesAllocationUniqueChecker(newSalesAllocations);		
		// we will delegate the call to an async mechanism
		SalesAllocationsService.getInstance().manageTeamMemberVisibility(newSalesAllocations, oldSalesAllocationsById, true);

        /*VisibilityTeamMemberQueue visibilityQueue = new VisibilityTeamMemberQueue(newSalesAllocations, oldSalesAllocationsById, true);
        System.enqueueJob(visibilityQueue);*/
		//SalesAllocationsService.getInstance().updateRequestForSalesAllocations(newSalesAllocations, oldSalesAllocationsById);
		// This call is intended to be removed and replaced by manageTeamMemberVisibility
		// SalesAllocationsService.getInstance().updateSalesAllocVisibility(newSalesAllocations, oldSalesAllocationsById, true);
	}

	
	public override void beforeUpdate() {
		SalesAllocationsService.getInstance().setSalesAllocationUniqueChecker(newSalesAllocations);
		// we will delegate the call to an async mechanism
		SalesAllocationsService.getInstance().manageTeamMemberVisibility(newSalesAllocations, oldSalesAllocationsById, false);
        /*VisibilityTeamMemberQueue visibilityQueue = new VisibilityTeamMemberQueue(newSalesAllocations, oldSalesAllocationsById, false);
        System.enqueueJob(visibilityQueue);*/
		SalesAllocationsService.getInstance().updateRequestForSalesAllocations(newSalesAllocations, oldSalesAllocationsById);
		// This call is intended to be removed and replaced by manageTeamMemberVisibility
		// SalesAllocationsService.getInstance().updateSalesAllocVisibility(newSalesAllocations, oldSalesAllocationsById, false);
	}

	
    

}