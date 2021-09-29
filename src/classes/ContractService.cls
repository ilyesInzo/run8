/**
* @description Service class for interacting with Contract
* @author MDK
* @date 08/12/2017
*/
public class ContractService {

    ///////////////////////////////////////////////////////////////////////////////
    // WHEN CHILD CLASS EXTENDS AN ABSTRACT PARENT CLASS WE CAN'T USE STATIC METHOD
    // OF THE PARENT SO WE HAVE TO IMPLEMENT THE SINGLETON PATTERN
    ///////////////////////////////////////////////////////////////////////////////   
    private static ContractService instance = null;
    
    private ContractService() {
    }
     
    public static ContractService getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if (instance == null) {
            instance = new ContractService();
        }
        return instance;
    }
    ///////////////////////////////////////////////////////////////////////////////
    
    public class BadException extends Exception {}
    public class DuplicateFoundException extends Exception {}

    /**
     * @description 
     * @param 
     * @return 
     */
    public void alertContract(List<Contract> contracts){
        
        List<Id> month6conIds = new List<Id>();
        List<Id> month6contractIds = new List<Id>();
        List<Id> month12conIds = new List<Id>();
        List<Id> month12contractIds = new List<Id>();
        
        for(Contract cont :contracts ){
            if(cont.StartDate.addMonths(6) == date.today()){
                month6conIds.add(cont.CustomerSigned.Id);
                month6contractIds.add(cont.Id);
            }
            if(cont.StartDate.addMonths(12) == date.today()){
                month12conIds.add(cont.CustomerSigned.Id);      
                month12contractIds.add(cont.Id);      
            }
        }
        
        Id temp6month = [Select Id From EmailTemplate where DeveloperName =:'Contract_6_month'].Id;
        Id temp12month = [Select Id From EmailTemplate where DeveloperName =:'Contract_12_month'].Id;
        List<Messaging.MassEmailMessage> sendmassemail = new List<Messaging.MassEmailMessage>();
        
        if(!month6conIds.isEmpty()){
        Messaging.MassEmailMessage mail6 = new Messaging.MassEmailMessage();
        mail6.setTargetObjectIds(month6conIds);
        mail6.setWhatIds(month6contractIds);        
        mail6.setTemplateID(temp6month);
        sendmassemail.add(mail6);
        }
        
        if(!month12conIds.isEmpty()){
        Messaging.MassEmailMessage mail12 = new Messaging.MassEmailMessage();
        mail12.setTargetObjectIds(month12conIds);
        mail12.setWhatIds(month12contractIds);        
        mail12.setTemplateID(temp12month);
        sendmassemail.add(mail12);
        }
        
        Messaging.sendEmail(sendmassemail);   
    }
    
}