global class Batch_Objective_KAM_SharingRules implements Database.Batchable<SObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){

        return Database.getQueryLocator([Select Id, Account__c  From Sales_Allocations__c
                                         WHERE Update_Visibility__c = true ]);

    }

    global void execute(Database.BatchableContext BC, List<SObject> scope){
        List<Sales_Allocations__c> salesAlloclist = (List<Sales_Allocations__c>) scope;

        set<Id> salesAllocIds = new set<id>();
        for (Sales_Allocations__c sa: salesAlloclist){
            salesAllocIds.add(sa.Id);
        }
        Integer year = system.date.today().year()-1;
        list<Objectives__c> objectivesToUpdate = [Select Id, Account__c, Sub_Segment__c, Sales_Allocation__r.Account__c, Sales_Allocation__r.Product_Sub_Segment__c, Sales_Allocation__r.Valid_To__c, Sales_Allocation__r.Valid_From__c, Sales_Allocation__c,
                Sales_Allocation__r.Sales_Team__r.KAM__c, Sales_Allocation__r.Sales_Team__r.Manager__c, Sales_Allocation__r.Sales_Team__r.Director__c, Sales_Allocation__r.Sales_Team__r.Additional__c From Objectives__c
                where Sales_Allocation__c IN:salesAllocIds
                and Calendar_Year(Date__c) >=: year  ];
        System.debug('@@@ objectivesToUpdate: '+ objectivesToUpdate.size());

        AP01_Objective_Rules.kamObjectiveshare(objectivesToUpdate);

    }


    global void finish(Database.BatchableContext BC){
        Database.executeBatch(new Batch_SalesAlloc_UncheckFlagVisibility(),50);
    }
}