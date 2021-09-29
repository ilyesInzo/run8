global class Batch_SalesAlloc_UncheckFlagVisibility implements Database.Batchable<SObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){

    return Database.getQueryLocator([Select Id
                                    from Sales_Allocations__c
                                    where Update_Visibility__c = true]);

    }

    global void execute(Database.BatchableContext BC, List<SObject> scope){
        list<Sales_Allocations__c> SalesAll = scope;
        for (Sales_Allocations__c sa:SalesAll ){
        sa.Update_Visibility__c = false;
        }
        update SalesAll;
    }


    global void finish(Database.BatchableContext BC){
		Database.executeBatch(new BA01_Opportunity_Owner(),50);
    }
}