/**
 * Created by Thanina on 11/07/2019.
 */

public class SimpleLookupApexController {

	@AuraEnabled
	public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, String queryFilters) {
		system.debug('ObjectName-->' + ObjectName);

		String searchKey = searchKeyWord + '%';

		String usrId = UserInfo.getUserId();

		List < sObject > lstOfRecords = new List < sObject > ();

		//Added by Thanina , pour permettre au functionnal Admin and  Sys Admin need to see all account: Start ID

		// User u = [select id, Profile.Name from User where id = :usrId];

		String sQuery = '';
		if(queryFilters!= null && queryFilters.trim()!= '') {
			sQuery =  'select id, Name from ' +ObjectName + ' where (LastName LIKE: searchKey or FirstName LIKE: searchKey) and (Profile.Name = \'SALES - KAM\')  ' + queryFilters.trim() + '  order by Name asc limit 5';
		} 
		else  sQuery =  'select id, Name from ' +ObjectName + ' where (LastName LIKE: searchKey or FirstName LIKE: searchKey) and (Profile.Name = \'SALES - KAM\') order by Name asc limit 5';
		//  if(u.Profile.Name.equalsIgnoreCase('System Administrator') || u.Profile.Name.equalsIgnoreCase('Functionnal Administrator'))


			//------- End Id----------------
			//    else sQuery =  'select id, Name, Account_Key_Formula__c from ' +ObjectName + ' where Name LIKE: searchKey and id in :setIds order by createdDate DESC limit 5';

		lstOfRecords = Database.query(sQuery)
			;


		return lstOfRecords;
	}
}