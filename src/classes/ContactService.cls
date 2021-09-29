/**
* @description Service class for interacting with Contact
* @author MDK
* @date 08/12/2017
*/
public class ContactService {

    ///////////////////////////////////////////////////////////////////////////////
    // WHEN CHILD CLASS EXTENDS AN ABSTRACT PARENT CLASS WE CAN'T USE STATIC METHOD
    // OF THE PARENT SO WE HAVE TO IMPLEMENT THE SINGLETON PATTERN
    ///////////////////////////////////////////////////////////////////////////////   
    private static ContactService instance = null;
    
    private ContactService() {
    }
     
    public static ContactService getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if (instance == null) {
            instance = new ContactService();
        }
        return instance;
    }
    ///////////////////////////////////////////////////////////////////////////////
    
    public class BadException extends Exception {}
    public class DuplicateFoundException extends Exception {}
    
    
    public static void calculateGamification(List<Contact> newContacts, String badge){
        
        Boolean calculate = true;
        Id userRT = [select Id from RecordType where SobjectType =:'Contact' and DeveloperName =: 'User'].Id;
        
        for(Contact ct:newContacts){
            if(ct.Contact_typ__c == 'User' && ct.RecordTypeId == userRT){
                calculate = false;
            }
        }
        
        if(calculate == true){
            LC02_CalculateGamificationPoints.calculatePoints(badge);
        }
    } 
   

}