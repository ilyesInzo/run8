public with sharing class unCheckUpdateRequestSalesAllocation {
	
	@InvocableMethod(label='Uncheck Update Request Sales Allocation field on user')
    public static void unCheckField(List<User> liUsers) {
		System.debug('@@qama Uncheck USER RECORDs ---- '+liUsers)      ; 
		List<User> liUsersToUpdate =  new list<USer>();
		map<id,User> mapUsersToUpdate =  new map<id,USer>();
		  
		//Update checkbox if not checked
		for(User usr  : liUsers){
			//update only if not checked
			if(usr.Update_Request_Sales_Alloc__c == true && mapUsersToUpdate.get(usr.id)==null){
				usr.Update_Request_Sales_Alloc__c = false;
				mapUsersToUpdate.put(usr.id,usr);
				liUsersToUpdate.add(usr);
			}	
		}//end update
		
		update liUsersToUpdate;
    
}
}