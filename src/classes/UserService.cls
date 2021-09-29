/**
* @description Service class for interacting with User
* @author MDK
* @date 07/11/2017
*/
public class UserService extends ParentService {

    /**
     * Cache
     */
    public static Boolean useFromCache = true;
    public static Boolean useToCache = true;
    public override Boolean useFromCache() {
        return useFromCache;
    }
    public override Boolean useToCache() {
        return useToCache;
    }

    /**
     * [getUser description]
     * @param  userIds [description]
     * @return         [description]
     */
    public Map<Id, User> getUser(Set<Id> userIds) {
        System.debug('UserService.getUser userIds=' + userIds);
        // Get cache
        String methodName = 'UserService.getUser';
        List<User> usersList = (List<User>) getFromCache(methodName, userIds);
        if (userIds != null && !userIds.isEmpty() && usersList == null) {
            // Requete SOQL
            usersList = [
                SELECT Id,Name,UserName,UserRoleId,Email,ProfileId,Profile.Name 
                FROM User 
                WHERE Id=:userIds
            ];
            // Put cache
            putInCache(methodName, userIds, usersList);
        }
        if (usersList == null) {
            usersList = new List<User>();
        }
        // Objet retour
        Map<Id, User> usersMap = new Map<Id, User>(usersList);
        return usersMap;
    }

	/**
     * @description checkMatriculeADSUserSales
     * @param newUsersById
     * @return void
     */
	public static void checkMatriculeADSUserSales(List<User> newUsers, List<User> oldUsers) {
    	    	            
        //Loop to retrieve all Unic_Key__c values
        Set<String> newMatricules = new Set<String>();
        for (User u : newUsers)
        {
            if(!newMatricules.contains(u.Matricule_ADS_Pad__c)) {
                newMatricules.add(u.Matricule_ADS_Pad__c);
            }
            else {
                u.addError(System.label.USER_CHECKMATRICULE_ERRMSG);
            }
        }
                
        //SoQL to get existing User with this key
        //WARNING HERE YOU MIGHT REACH LIMITS IF YOU HAVE MANY DUPLICATES (SoQL Rows...)               
        Set<Id> userIds = SObjectUtils.toSetOfId(oldUsers);
        List<User> users = [
            	Select Matricule_ADS_Pad__c 
            	From User where Matricule_ADS__c <> '' 
            	And Id Not In :userIds
            	And Matricule_ADS_Pad__c In :newMatricules];

        Set<String> currentMatricules = SObjectUtils.toSetOfString(users,'Matricule_ADS_Pad__c'); 
        
        //Loop again through your Updated/Inserted User
        for (User u : newUsers)
        {
            if (currentMatricules.contains(u.Matricule_ADS_Pad__c))
            {
                //Here you may require some more processing if you want to exclude 1 value from being unique 
                u.addError(System.label.USER_CHECKMATRICULE_ERRMSG); 
            }   
            
        }    

	}

	/**
     * @description checkMatriculeADSUserSales
     * @param newUsers
     * @return void
     */
	public static void checkMatriculeADSUserSales(List<User> newUsers) {
		checkMatriculeADSUserSales(newUsers, null);
	}






}