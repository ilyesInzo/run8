public class LC02_gamificationController {

	@AuraEnabled
	public static Contact getContactInfos(Id userId) {
		Id userRT = [select Id from RecordType where SobjectType = :'Contact' and DeveloperName = :'User'].Id;
		List<User> currentUser = [select id, Name, FirstName, LastName, Email from User where id = :userId];
		if(currentUser.size() > 0) {
			List<Contact> contactToReturn = [select id, Name, Rank_Name__c, Total_won_points__c, Nb_of_badges__c from Contact
										     where Email = :currentUser [0].Email and FirstName = :currentUser [0].FirstName
										     and LastName = :currentUser [0].LastName and recordTypeId = :userRT];
			if(contactToReturn.size() > 0) {
				return contactToReturn [0];
			} else {

				List<Account> acc = [select id, Name from Account where Name = :AP00_UtilityConstants.ACCOUNT_GAMIFICATION_ACCOUNT_NAME];

				if(acc.size() > 0) {
					Contact newContact = new Contact(FirstName = currentUser [0].FirstName, 
												     LastName = currentUser [0].LastName, 
												     Salutation = 'Mr', 
												     Email = currentUser [0].Email, 
												     Contact_typ__c = AP00_UtilityConstants.CONTACT_CONTACT_TYPE_USER, 
												     RecordTypeId = userRT, 
												     AccountId = acc [0].id, 
												     TECH_User__c = 'user');
					insert newContact;
					List<Contact> contactToReturn1 = [select id, Name, Rank_Name__c, Total_won_points__c, Nb_of_badges__c from Contact
												      where Email = :currentUser [0].Email and FirstName = :currentUser [0].FirstName
												      and LastName = :currentUser [0].LastName and recordTypeId = :userRT];

					if(contactToReturn1.size() > 0) {
						return contactToReturn1 [0]; }
				}

			}
		}
		return null;
	}
}