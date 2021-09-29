global class BA01_Objective_Rules implements Database.Batchable<SObject>{

    //NOTE : This batch is dependent on objectives being created prior to calculation,batch BA00_Create_Objective_Rules must always be run before.

    //Could be used in test case
    Public String query='';
 	private static final Integer year = system.today().year()-1;
    private static final Integer nextYear = system.today().year()+1;
    global Database.QueryLocator start(Database.BatchableContext BC){
        if (query=='') {
           
            query = 'Select Id, Date__c, Account__c, Sub_Segment__c,Plant__c,Plant__r.Plant_Code__c,Plant__r.Name  FROM Objectives__c';
            query += ' Where Calendar_Year(Date__c) >=:year and Calendar_Year(Date__c) <=:nextYear';
            query+=' Order by Date__c ASC';
        }
        return Database.getQueryLocator(query);

    }

    global void execute(Database.BatchableContext BC, List<SObject> scope){

        List<Objectives__c> lObjectives= (List<Objectives__c>) scope;
        if (lObjectives!= null && lObjectives.size()>0) {
            AP01_Objective_Rules.ObjectiveNetNewBusiness(lObjectives);
            AP01_Objective_Rules.ObjectiveLostRetention(lObjectives);
            AP01_Objective_Rules.ObjectiveWonContract(lObjectives);
        }
    }


    global void finish(Database.BatchableContext BC){

        //Launch Sharing Rules Batches
        Database.executeBatch(new BA01_Objective_Plant_SharingRules());
    }
}