@isTest
private class SimpleLookupApexControllerTest {
	@testSetup
	private static void MyJDD() {
		//Creation of user
		//User testUser = new User(FirstName = 'Sabri', LastName = 'Guessoum');
		//List<User> stUsers = new List<User>();
		//stUsers.add(TestFactory.newKamUser(1000));

		User u1 = TestFactory.newUser('SALES - KAM', 1234);
		insert u1;

		//insert stUsers;
		//insert testUser;
	}

	@isTest
	private static void Mytest() {
		//Test usersize result if 1 or 0
		Test.startTest();
		list<Object> result= SimpleLookupApexController.fetchLookUpValues('Foo', 'user', Null);
		System.assertEquals(result.size(), 1);

		list<Object> result2 =SimpleLookupApexController.fetchLookUpValues('Zak', 'user', Null);
		System.assertEquals(result2.size(), 0);
		Test.stopTest();

	}
}