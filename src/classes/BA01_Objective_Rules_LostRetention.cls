global class BA01_Objective_Rules_LostRetention implements Database.Batchable<SObject>{
    
    //NOTE :Deprecated , Lost Retention is already Calculated in BA01_Objective_Rules
    
    //Could be used in test case
    Public String query;
        
    global Database.QueryLocator start(Database.BatchableContext BC){
        if (query=='') {
            Integer year=0;
            try { year = Integer.valueOf(System.Label.LBL_Reference_Year_For_Objectives_Calculation);} catch(exception e){ year=0;}
            query = 'Select Id, Date__c, Account__c, Sub_Segment__c FROM Objectives__c';
            if (year > 0)
                query += ' Where CALENDAR_YEAR(Date__c) >=:year';
            query+=' Order by Date__c ASC';
        }
        return Database.getQueryLocator(query);
    } 
        
    global void execute(Database.BatchableContext BC, List<SObject> scope){
    
        List<Objectives__c> lObjectives= (List<Objectives__c>) scope;
        if (lObjectives!= null && lObjectives.size()>0)
            AP01_Objective_Rules.ObjectiveLostRetention(lObjectives);
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}