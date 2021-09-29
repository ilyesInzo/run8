/**
* Service class for interacting with All Service
*
* @author MDK
* @date 20/12/2017
*
*/
public abstract class ParentService {

    /**
     * Cache
     */
    public static Boolean useFromCache = true;
    public static Boolean useToCache = true;
    public virtual Boolean useFromCache() {
        return useFromCache;
    }
    public virtual Boolean useToCache() {
        return useToCache;
    }

    /**
     * [getFromCache description]
     * @param  methodName [description]
     * @param  ids        [description]
     * @return            [description]
     */
    public virtual List<Object> getFromCache(String methodName, Set<Id> ids) {
        List<Object> objects = null;
        if (useFromCache()) {
            objects = CacheUtils.get(methodName, ids);
        }
        return objects;
    }

    /**
     * [putInCache description]
     * @param methodName   [description]
     * @param ids          [description]
     * @param List<Object> [description]
     */
    public virtual void putInCache(String methodName, Set<Id> ids, List<Object> objects) {
        if (useToCache()) {
            CacheUtils.put(methodName, ids, objects);
        }
    }

    /**
     * [getFromCache description]
     * @param  methodName [description]
     * @param  names      [description]
     * @return            [description]
     */
    /*public virtual List<Object> getFromCache(String methodName, Set<String> names) {
        List<Object> objects = null;
        if (useFromCache()) {
            objects = CacheUtils.get(methodName, names);
        }
        return objects;
    }*/

    /**
     * [putInCache description]
     * @param methodName   [description]
     * @param names        [description]
     * @param List<Object> [description]
     */
    /*public virtual void putInCache(String methodName, Set<String> names, List<Object> objects) {
        if (useToCache()) {
            CacheUtils.put(methodName, names, objects);
        }
    }*/

    /**
     * [getFromCache description]
     * @param  methodName [description]
     * @return            [description]
     */
    /*public virtual List<Object> getFromCache(String methodName) {
        List<Object> objects = null;
        if (useFromCache()) {
            objects = CacheUtils.get(methodName);
        }
        return objects;
    }*/

    /**
     * [putInCache description]
     * @param methodName   [description]
     * @param List<Object> [description]
     */
    /*public virtual void putInCache(String methodName, List<Object> objects) {
        if (useToCache()) {
            CacheUtils.put(methodName, objects);
        }
    }*/
}