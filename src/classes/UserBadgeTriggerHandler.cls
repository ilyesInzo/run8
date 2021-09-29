public class UserBadgeTriggerHandler extends TriggerHandler{
 
    private Map<Id,User_Badge__c> oldUserBadgesById;
    private Map<Id,User_Badge__c> newUserBadgesById;
    private List<User_Badge__c> newUserBadges; 
    private List<User_Badge__c> oldUserBadges;

    public UserBadgeTriggerHandler() {
        this.oldUserBadgesById = (Map<Id, User_Badge__c>) Trigger.oldMap;
        this.newUserBadgesById = (Map<Id, User_Badge__c>) Trigger.newMap;
        this.newUserBadges = (List<User_Badge__c>) Trigger.new;
        this.oldUserBadges = (List<User_Badge__c>) Trigger.old; 
    }
        
    public override void beforeUpdate() {   		
	    UserBadgeService.winBadge(newUserBadgesById);
    }
 
    public override void beforeInsert() {
		//UserBadgeService.winBadge(newUserBadgesById);
    }
   
}