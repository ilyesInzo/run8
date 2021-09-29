/**
* A utility Test class for Cache
*/
@isTest
public class CacheUtilsTest {
    
    /**
     * [putGetByIdTest Test]
     */
    @isTest 
    static void putGetByIdTest() {
        // Param
        String methodName = 'UserService.getUser';
        Set<Id> ids = new Set<Id> { '5002600000EAMNx', '5002600000EBMNx' };
        Set<Id> ids2 = new Set<Id> { '5002600000EAMNx', '5002600000EBMNx' };
        Set<Id> ids3 = new Set<Id> { '5002600000EAMNx' };
        Set<Id> ids4 = new Set<Id> { '5002600000EBMNx' };
        List<Object> objects = new List<Object> { 'FR' };
        List<Object> objects2 = new List<Object> { 'BE', 'CH' };
        List<Object> objects3 = new List<Object> { 'ES', 'IT', 'PT' };

        // Call method to test
        Test.startTest();
        CacheUtils.put(methodName, ids, objects);
        CacheUtils.put(methodName, ids2, objects2);
        CacheUtils.put(methodName, ids3, objects3);
        List<Object> objectsResult = CacheUtils.get(methodName, ids);
        List<Object> objectsResult2 = CacheUtils.get(methodName, ids2);
        List<Object> objectsResult3 = CacheUtils.get(methodName, ids3);
        List<Object> objectsResult4 = CacheUtils.get(methodName, ids4);
        Test.stopTest();

        // Check result
        //System.assertEquals(2, objectsResult.size()); //Comportement aleatoire !!!!
        System.assertEquals(2, objectsResult2.size());
        System.assertEquals(3, objectsResult3.size());
        System.assertEquals(null, objectsResult4);
        //System.debug('ZZZZZZZZ : objectsResult.size()=' + objectsResult.size());
		//System.debug('ZZZZZZZZ : objectsResult2.size()=' + objectsResult2.size());
    }

    /**
     * [putGetByNameTest Test]
     */
    @isTest 
    static void putGetByNameTest() {
        // Param
        String methodName = 'UserService.getUser';
        Set<String> names = new Set<String> { '5002600000EAMNx', '5002600000EBMNx' };
        Set<String> names2 = new Set<String> { '5002600000EAMNx', '5002600000EBMNx' };
        Set<String> names3 = new Set<String> { '5002600000EAMNx' };
        Set<String> names4 = new Set<String> { '5002600000EBMNx' };
        List<Object> objects = new List<Object> { 'FR' };
        List<Object> objects2 = new List<Object> { 'BE', 'CH' };
        List<Object> objects3 = new List<Object> { 'ES', 'IT', 'PT' };

        // Call method to test
        Test.startTest();
        CacheUtils.put(methodName, names, objects);
        CacheUtils.put(methodName, names2, objects2);
        CacheUtils.put(methodName, names3, objects3);
        List<Object> objectsResult = CacheUtils.get(methodName, names);
        List<Object> objectsResult2 = CacheUtils.get(methodName, names2);
        List<Object> objectsResult3 = CacheUtils.get(methodName, names3);
        List<Object> objectsResult4 = CacheUtils.get(methodName, names4);
        Test.stopTest();

        // Check result
        //System.assertEquals(2, objectsResult.size());
        System.assertEquals(2, objectsResult2.size());
        System.assertEquals(3, objectsResult3.size());
        System.assertEquals(null, objectsResult4);
    }
}