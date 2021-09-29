global class BA00_ReAffect_Objective_Rules implements Database.Batchable<SObject>{
	
    public String Query ;
    
	global Database.QueryLocator start(Database.BatchableContext BC){		  
    	Query = 'SELECT id, Sub_Segment__c, Account__c, alloc_valid_to_date__c, Sales_Allocation__r.Sales_Allocation_Unique_Checker__c';
    	Query +=' FROM Objectives__c';
       	Query +=' WHERE alloc_valid_to_date__c < TODAY OR alloc_valid_to_date__c= null ';
        
        system.debug('--- Query ---'+Query);
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope){
    
		list<Objectives__c> lObjectives = scope;
        AP01_Objective_Rules.objectiveReAffectation(lObjectives);
        
    }
    
    global void finish(Database.BatchableContext BC){       
       
        
    }
	
	
    
}