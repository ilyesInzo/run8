public class AccountTriggerHandler extends TriggerHandler {
   
    private Map<Id,Account> oldAccountsById;
    private Map<Id,Account> newAccountsById;
    private List<Account> newAccounts; 
    private List<Account> oldAccounts;

    public AccountTriggerHandler() {
        this.oldAccountsById = (Map<Id, Account>) Trigger.oldMap;
        this.newAccountsById = (Map<Id, Account>) Trigger.newMap;
        this.newAccounts = (List<Account>) Trigger.new;
        this.oldAccounts = (List<Account>) Trigger.old; 
    }
        
    public override void beforeUpdate() {

        SObjectUtils.checkChar(newAccounts);
        
    }

    public override void beforeInsert() {
        
        SObjectUtils.checkChar(newAccounts);
        
    }
    
	public override void afterInsert() {
        
        LC02_CalculateGamificationPoints.calculatePoints(AP00_UtilityConstants.BADGE_ACCOUNT_CREATION);
        
    }
}