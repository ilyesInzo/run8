public class UserTriggerHandler extends TriggerHandler {
   
    private Map<Id,User> oldUsersById;
    private Map<Id,User> newUsersById;
    private List<User> newUsers; 
    private List<User> oldUsers;

    public UserTriggerHandler() {
        this.oldUsersById = (Map<Id, User>) Trigger.oldMap;
        this.newUsersById = (Map<Id, User>) Trigger.newMap;
        this.newUsers = (List<User>) Trigger.new;
        this.oldUsers = (List<User>) Trigger.old; 
    }
        
    public override void beforeUpdate() {
        UserService.checkMatriculeADSUserSales(newUsers, oldUsers);        
    }

    public override void beforeInsert() {        
        UserService.checkMatriculeADSUserSales(newUsers);        
    }   

}