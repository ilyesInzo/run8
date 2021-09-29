global class BA01_Opportunity_Owner implements Database.Batchable<SObject>{
    
    public String query = '';
        
    global Database.QueryLocator start(Database.BatchableContext BC){
        if (query=='') {
            Integer year=0;
            query = 'Select Id, ownerID,owner.ISM_Team_Member__c, Sales_Allocation_Id__r.sales_team__r.kam__c, StageName FROM Opportunity';
           /* query += ' Where stageName in (\'Needs Analysis\',\'Proposal\',\'Negotiation\') ';*/
            query+=' Where Sales_Allocation_Id__c != null AND  Sales_Allocation_Id__r.sales_team__r.kam__c !=null AND Sales_Allocation_Id__r.valid_to__c >= TODAY ';
        }
        return Database.getQueryLocator(query);
    
    }  
        
    global void execute(Database.BatchableContext BC, List<SObject> scope){
    
        List<Opportunity> liOpportunitiesToProcess = (List<Opportunity>) scope;
        //update Opportunity owners
        OpportunityService.updateOpptyOwnerId(liOpportunitiesToProcess);
    } 
    
    
    global void finish(Database.BatchableContext BC){
        
    }
        

}