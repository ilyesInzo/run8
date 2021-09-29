global class BA01_CountObjectifAccount implements Database.Batchable<SObject>{
    
    public String query = 'select Id,OwnerId, Number_of_Bronze_clients__c,Number_of_Gold_clients__c,Number_of_Platinum_clients__c , Number_of_Silver_clients__c from KAM_Objectives__c ';
        
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(query);
    
    } 
        
    global void execute(Database.BatchableContext BC, List<SObject> scope){
    
        List<KAM_Objectives__c> KamObjectifList = (List<KAM_Objectives__c>) scope;
        ObjectifLineService.updateNumberOfClient(KamObjectifList);
    }
    
    
    global void finish(Database.BatchableContext BC){
        
    }
        

}