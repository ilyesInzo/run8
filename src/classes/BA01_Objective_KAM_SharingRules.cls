global class BA01_Objective_KAM_SharingRules implements Database.Batchable<SObject>{
    
        
    global Database.QueryLocator start(Database.BatchableContext BC){
        integer    year = Integer.valueOf(System.Label.LBL_Reference_Year_For_Objectives_Calculation);     
        return Database.getQueryLocator([Select Id, Account__c, Sub_Segment__c, Sales_Allocation__r.Account__c, Sales_Allocation__r.Product_Sub_Segment__c, Sales_Allocation__r.Valid_To__c, Sales_Allocation__r.Valid_From__c, Sales_Allocation__c,
        Sales_Allocation__r.Sales_Team__r.KAM__c, Sales_Allocation__r.Sales_Team__r.Manager__c, Sales_Allocation__r.Sales_Team__r.Director__c, Sales_Allocation__r.Sales_Team__r.Additional__c From Objectives__c 
        WHERE Sales_Allocation__r.Product_Sub_Segment__c != null and Sales_Allocation__r.Account__c != null and Calendar_Year(Date__c) >=:year ]);
    
    } 
        
    global void execute(Database.BatchableContext BC, List<SObject> scope){
    
        List<Objectives__c> objectivelist = (List<Objectives__c>) scope;
        AP01_Objective_Rules.kamObjectiveshare(objectivelist);
    }
    
    
    global void finish(Database.BatchableContext BC){
    	Database.executeBatch(new BA01_Objective_Plant_SharingRules());        
    }
        

}