/**
* A utility class for Cache
*
* @author MDK
* @date 20/12/2017
*
*/
public class CacheUtils {

    // Fonction => Nom Param => Valeur Param => Objet
    //private static Map<String, Map<Id, Object>> MAP_BY_ID_BY_DEVELOPER_NAME = new Map<String, Map<String, RecordType>>();

    // Fonction => Set<Id> => List<Object>
    // UserService.getUser => Set<Id>
    private static Map<String, Map<Set<Id>, List<Object>>> OBJECTS_BY_IDS_BY_METHOD = new Map<String, Map<Set<Id>, List<Object>>>();

    // Fonction => Set<String> => List<Object>
    // UserService.getUser => Set<String>
    private static Map<String, Map<Set<String>, List<Object>>> OBJECTS_BY_NAMES_BY_METHOD = new Map<String, Map<Set<String>, List<Object>>>();

    /**
     * [get description]
     * @param  methodName [description]
     * @param  ids        [description]
     * @return            [description]
     */
    public static List<Object> get(String methodName, Set<Id> ids) {
        System.debug('CacheUtils.get(String methodName, Set<Id> ids)');
        List<Object> objects = null;
        Map<Set<Id>, List<Object>> objectsByIds = OBJECTS_BY_IDS_BY_METHOD.get(methodName);
        if (objectsByIds != null) {
            objects = objectsByIds.get(ids);
        }
        return objects;
    }

    /**
     * [put description]
     * @param  methodName [description]
     * @param  ids        [description]
     * @param  objects    [description]
     * @return            [description]
     */
    public static void put(String methodName, Set<Id> ids, List<Object> objects) {
        System.debug('CacheUtils.put(String methodName, Set<Id> ids, List<Object> objects)');
        Map<Set<Id>, List<Object>> objectsByIds = OBJECTS_BY_IDS_BY_METHOD.get(methodName);
        if (objectsByIds == null) {
            objectsByIds = new Map<Set<Id>, List<Object>>();
            OBJECTS_BY_IDS_BY_METHOD.put(methodName, objectsByIds);
        }
        objectsByIds.put(ids, objects);
        System.debug('CacheUtils.put : OBJECTS_BY_IDS_BY_METHOD.objectsByIds.size() : ' + objectsByIds.size());
        //System.debug('CacheUtils.put : OBJECTS_BY_IDS_BY_METHOD=' + OBJECTS_BY_IDS_BY_METHOD.size());
        //System.debug('CacheUtils.put : OBJECTS_BY_IDS_BY_METHOD.MethodName=' + OBJECTS_BY_IDS_BY_METHOD.get(methodName).size());
    }

    /**
     * [get description]
     * @param  methodName [description]
     * @param  names      [description]
     * @return            [description]
     */
    public static List<Object> get(String methodName, Set<String> names) {
        System.debug('CacheUtils.get(String methodName, Set<String> names)');
        List<Object> objects = null;
        Map<Set<String>, List<Object>> objectsByIds = OBJECTS_BY_NAMES_BY_METHOD.get(methodName);
        if (objectsByIds != null) {
            objects = objectsByIds.get(names);
        }
        return objects;
    }

    /**
     * [put description]
     * @param methodName [description]
     * @param names      [description]
     * @param objects    [description]
     */
    public static void put(String methodName, Set<String> names, List<Object> objects) {
        System.debug('CacheUtils.put(String methodName, Set<String> names, List<Object> objects)');
        Map<Set<String>, List<Object>> objectsByIds = OBJECTS_BY_NAMES_BY_METHOD.get(methodName);
        if (objectsByIds == null) {
            objectsByIds = new Map<Set<String>, List<Object>>();
            OBJECTS_BY_NAMES_BY_METHOD.put(methodName, objectsByIds);
        }
        objectsByIds.put(names, objects);
        System.debug('CacheUtils.put : OBJECTS_BY_NAMES_BY_METHOD.objectsByIds.size() : ' + objectsByIds.size());
        //System.debug('CacheUtils.put : OBJECTS_BY_NAMES_BY_METHOD=' + OBJECTS_BY_NAMES_BY_METHOD.size());
        //System.debug('CacheUtils.put : OBJECTS_BY_NAMES_BY_METHOD.MethodName=' + OBJECTS_BY_NAMES_BY_METHOD.get(methodName).size());
    }

    /**
     * [get description]
     * @param  methodName [description]
     * @return            [description]
     */
    /*public static List<Object> get(String methodName) {
        System.debug('CacheUtils.get(String methodName)');
        List<Object> objects = null;
        Map<Set<String>, List<Object>> objectsByIds = OBJECTS_BY_NAMES_BY_METHOD.get(methodName);
        if (objectsByIds != null) {
            objects = objectsByIds.get(null);
        }
        return objects;
    }*/

    /**
     * [put description]
     * @param methodName [description]
     * @param names      [description]
     * @param objects    [description]
     */
    /*public static void put(String methodName, List<Object> objects) {
        System.debug('CacheUtils.put(String methodName, List<Object> objects)');
        Map<Set<String>, List<Object>> objectsByIds = OBJECTS_BY_NAMES_BY_METHOD.get(methodName);
        if (objectsByIds == null) {
            objectsByIds = new Map<Set<String>, List<Object>>();
            OBJECTS_BY_NAMES_BY_METHOD.put(methodName, objectsByIds);
        }
        objectsByIds.put(null, objects);
        System.debug('CacheUtils.put : OBJECTS_BY_NAMES_BY_METHOD.objectsByIds.size() : ' + objectsByIds.size());
        //System.debug('CacheUtils.put : OBJECTS_BY_NAMES_BY_METHOD=' + OBJECTS_BY_NAMES_BY_METHOD.size());
        //System.debug('CacheUtils.put : OBJECTS_BY_NAMES_BY_METHOD.MethodName=' + OBJECTS_BY_NAMES_BY_METHOD.get(methodName).size());
    }*/

}