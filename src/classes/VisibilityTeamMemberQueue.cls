/**
 * Created by user on 29/09/2021.
 */

public with sharing class VisibilityTeamMemberQueue implements Queueable{

    private Map<Id,Sales_Allocations__c> oldSalesAllocationsById;
    private List<Sales_Allocations__c> newSalesAllocations;
    private Boolean isInsert;

    public VisibilityTeamMemberQueue(List<Sales_Allocations__c>newSalesAllocations, Map<Id,Sales_Allocations__c> oldSalesAllocationsById, Boolean isInsert){
        this.isInsert = isInsert;
        this.oldSalesAllocationsById = oldSalesAllocationsById;
        this.newSalesAllocations = newSalesAllocations;
    }


    public void execute(QueueableContext qc){
        SalesAllocationsService.getInstance().manageTeamMemberVisibility(newSalesAllocations, oldSalesAllocationsById, isInsert);
    }


}