public class UserBadgeService {

    ///////////////////////////////////////////////////////////////////////////////
    // WHEN CHILD CLASS EXTENDS AN ABSTRACT PARENT CLASS WE CAN'T USE STATIC METHOD
    // OF THE PARENT SO WE HAVE TO IMPLEMENT THE SINGLETON PATTERN
    ///////////////////////////////////////////////////////////////////////////////   
    private static UserBadgeService instance = null;
   
    ///////////////////////////////////////////////////////////////////////////////
    
    public class BadException extends Exception {}
    public class DuplicateFoundException extends Exception {}
    
    
    public static void winBadge(Map<id,User_Badge__c> newUserBadge){
        Map<id,User_Badge__c> userbadges = new Map<id,User_Badge__c>([select id,Name,Won_points__c,
                                                                      	Badge__c,Badge__r.Points_to_win__c 
                                                                      from User_Badge__c where id in : newUserBadge.keySet()]);
        
        for(User_Badge__c ub : newUserBadge.values()){
            System.debug('AAA' + ub.Badge__r.Points_to_win__c);
            if(ub.Won_points__c >= Decimal.valueof(userbadges.get(ub.id).Badge__r.Points_to_win__c)) ub.Won__c = true;
            else ub.Won__c = false;
            
        }
	        
    } 
   

}