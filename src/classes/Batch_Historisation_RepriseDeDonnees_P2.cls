global class Batch_Historisation_RepriseDeDonnees_P2 implements Database.Batchable<SObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
                
        return Database.getQueryLocator([select Id  
                                         from PM_Selected_Dipsensing_config__c 
                                         where Quote_Item__r.copy_Quote_Status__c = 'Draft']);
        
    } 
        
    global void execute(Database.BatchableContext BC, List<SObject> scope){
        list<PM_Selected_Dipsensing_config__c> selectedConfig = scope;
        update selectedConfig;
        

    }
    
    
    global void finish(Database.BatchableContext BC){
    	
    }
}