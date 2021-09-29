public class LC03_displayAccountFields {
    
    
    @AuraEnabled
    public static Void editDateHeliosCall (Id accountId){
        
        Integer intervalCall = Integer.ValueOf(Label.INTERVAL_HELIOS_CALL);
        
        if(intervalCall == Null) intervalCall = 0;
        
        List<Account> accountList = [select id, Name, Helios_Branch_Code__c,Tech_dateOfTheLastHeliosCall__c from Account
                                    where id =: accountId];
        
        if(accountList.size()>0){
            
            if(accountList[0].Tech_dateOfTheLastHeliosCall__c == null || accountList[0].Tech_dateOfTheLastHeliosCall__c.addMinutes(intervalCall) < datetime.now()){
                System.debug('==>');
                accountList[0].Tech_dateOfTheLastHeliosCall__c = datetime.now();
                update accountList[0];        
            }
            
        }
        
    }
    

}