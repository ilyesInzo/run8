global class BA01_Contract_Reminder implements Database.Batchable<sObject>{
    
    private String query = 'Select Id, CustomerSigned.Id, StartDate, EndDate From Contract Where CustomerSignedId != null';

    global BA01_Contract_Reminder() {
     
    }

    global BA01_Contract_Reminder(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    } 
        
    global void execute(Database.BatchableContext BC, List<Contract> contractList){ 
        ContractService.getInstance().alertContract(contractList);
    }
    
    
    global void finish(Database.BatchableContext BC){
        
    }
        

}