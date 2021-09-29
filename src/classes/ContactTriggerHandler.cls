public class ContactTriggerHandler extends TriggerHandler{
 
    private Map<Id,Contact> oldContactsById;
    private Map<Id,Contact> newContactsById;
    private List<Contact> newContacts; 
    private List<Contact> oldContacts;

    public ContactTriggerHandler() {
        this.oldContactsById = (Map<Id, Contact>) Trigger.oldMap;
        this.newContactsById = (Map<Id, Contact>) Trigger.newMap;
        this.newContacts = (List<Contact>) Trigger.new;
        this.oldContacts = (List<Contact>) Trigger.old; 
    }
        
    public override void beforeUpdate() {
   		
        SObjectUtils.checkChar(newContacts); 	    
    }
 
    public override void beforeInsert() {

        SObjectUtils.checkChar(newContacts);    
    }
    
    public override void afterInsert() {
        ContactService.calculateGamification(newContacts,AP00_UtilityConstants.BADGE_CONTACT_CREATION);
        
    }
    
    public override void afterUpdate() {    
        ContactService.calculateGamification(newContacts,AP00_UtilityConstants.BADGE_CONTACT_UPDATE);       
    }
}