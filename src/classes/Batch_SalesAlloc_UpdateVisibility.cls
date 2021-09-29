global class Batch_SalesAlloc_UpdateVisibility implements Database.Batchable<SObject>{

global Database.QueryLocator start(Database.BatchableContext BC){

return Database.getQueryLocator([Select Id, Account__c  From Sales_Allocations__c
                                 WHERE Update_Visibility__c = true ]);



}

global void execute(Database.BatchableContext BC, List<SObject> scope){
    List<Sales_Allocations__c> salesAlloclist = (List<Sales_Allocations__c>) scope;

    set<Id> accountIds = new set<Id>();
    for (Sales_Allocations__c sa: salesAlloclist){
        accountIds.add(sa.Account__c);
    }
    Map<Id, Sales_Allocations__c> scopeSalesAlloc = new Map<Id, Sales_Allocations__c>([
                SELECT id, Sales_Allocations__c.Product_Sub_Segment__c, Sales_Allocations__c.Account__c,
                        Sales_Team__c,sales_team__r.Tech_Overlapped_SalesTeam__c, KAMF__c, Manager__c, Director__c,
                        Additional__c, Sales_Team__r.KAM__c,Sales_Team__r.KAM__r.isActive, Valid_To__c, Valid_From__c, Prod_Sub_Segment__c,
                        Sales_Team__r.Manager__c, Sales_Team__r.Manager__r.isActive, Sales_Team__r.Director__c,
                        Sales_Team__r.Director__r.isActive, Sales_Team__r.Additional__c, Sales_Team__r.Additional__r.isActive
                FROM Sales_Allocations__c
                WHERE Valid_From__c <= : Date.Today()
                AND Valid_To__c >= :Date.Today()
                AND Sales_Team__c != NULL
                AND Account__c IN: accountIds
    ]);
    SalesAllocationsService.applySalesAllocation(scopeSalesAlloc);

}


global void finish(Database.BatchableContext BC){
     Database.executeBatch(new Batch_Objective_KAM_SharingRules(),10);
}
}