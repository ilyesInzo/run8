/**
* @author Malha A.
* @date 28/01/2019 (Ticket 00006834)
*/

public  class  CreateNewOpportunityButtonController {
   
    @AuraEnabled
    public static Boolean checkCreationAccess (Id accountId){
        Id userId = UserInfo.getUserId();
        System.debug('@@ User Id: '+userId);
        System.debug('@@ Account Id: '+accountId);
        User currentUser = [SELECT Id,  Allow_Opportunity_Creation__c FROM User WHERE Id=:userId LIMIT 1];

        boolean result;
        if (currentUser.Allow_Opportunity_Creation__c == true){
            return true;
        }

        try{
             String query = 'select Id, UserId from AccountTeamMember where AccountId =\''+accountId+'\' and UserId = \''+userId + '\' limit 1';
             AccountTeamMember existingMember = Database.query(query);
             if (existingMember != null){
                result = true; // User is allowed to create opportunity
             }else {
                result = false; // User is not allowed to create opportunity
             }
        }catch(Exception e){
            result = false;
        }
        
       return result;

    }
}