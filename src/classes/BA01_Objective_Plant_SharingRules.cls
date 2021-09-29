global class BA01_Objective_Plant_SharingRules implements Database.Batchable<SObject>{
    
        
    global Database.QueryLocator start(Database.BatchableContext BC){
        Integer year = system.today().year();        
        return Database.getQueryLocator([Select Id, Plant__c From Objectives__c where Plant__c != null and Calendar_Year(Date__c) =:year]);
    
    } 
        
    global void execute(Database.BatchableContext BC, List<SObject> scope){
    
        List<Objectives__c> objectivelist = (List<Objectives__c>) scope;
        AP01_Objective_Rules.PlantObjectiveshare(objectivelist);
    }
    
    
    global void finish(Database.BatchableContext BC){
        Database.executeBatch(new BA01_Objective_SubSegment_SharingRules());
        
    }
        

}