global class BA01_Lead_Reminder implements Database.Batchable<SObject>{
    
    public date week1 = date.today() - 7;
    public date week2 =  date.today() - 14;
    public String query = 'select Id, OwnerId, Status from Lead where (LastModifiedDate__c =:week1 and Status =\'New\') OR (LastModifiedDate__c =:week2 and Status =\'Active\')';
        
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(query);
    
    } 
        
    global void execute(Database.BatchableContext BC, List<SObject> scope){
    
        List<Lead> leadList = (List<Lead>) scope;
        LeadService.alertlead(leadList);
    }
    
    
    global void finish(Database.BatchableContext BC){
        
    }
        

}