public with sharing class checkUpdateRequestSalesTeam {
    
    @InvocableMethod(label='uncheck Update Request Sales Team field on user')
    public static void unCheckField(List<User> liUsers) {
		System.debug('@@qama Uncheck USER RECORDs ---- '+liUsers)      ; 
		
		SET<ID> setIDUsers = new SET<ID>();
		List<ID> liIDUsers = new list<ID>();
		//fill set of users ids'
		for(User usr  : liUsers){
			setIDUsers.add(usr.ID);
		}
		liIDUsers.addAll(setIDUsers);
		
		//call future methode
		futureUncheckField(liIDUsers);		
    }
        
    @future(callout=true)
    public static void futureUncheckField(List<ID> liIDUsers){
    	List<User> liUsersToUpdate =  new list<USer>();
		map<id,User> mapUsersToUpdate =  new map<id,USer>();
		
		//Update checkbox if not checked
		for(User usr  : [select Update_Request_Sales_Team__c from user where id in :liIDUsers ]){
			//update only if not checked
			if(usr.Update_Request_Sales_Team__c == true && mapUsersToUpdate.get(usr.id)==null){
				usr.Update_Request_Sales_Team__c = false;
				mapUsersToUpdate.put(usr.id,usr);
				liUsersToUpdate.add(usr);
			}	
		}//end update
		
		update liUsersToUpdate;
    }
}