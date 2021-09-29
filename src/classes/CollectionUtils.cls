/**
* @description Utility class for Collection
* @author MDK
* @date 20/11/2017
*/
public class CollectionUtils {

    /**
     * [isEmpty description]
     * @param  l [description]
     * @return   [description]
     */
    /*public static Boolean isEmpty(List<Object> l) {
        Boolean isEmpty = false;
        if (l == null || l.isEmpty()) {
            isEmpty = true;
        }
        return isEmpty;
    }*/

    /**
     * [isNotEmpty description]
     * @param  l [description]
     * @return   [description]
     */
    /*public static Boolean isNotEmpty(List<Object> l) {
        return !isEmpty(l);
    }*/

    /**
     * [isEmpty description]
     * @param  s [description]
     * @return   [description]
     */
    /* Voir quand utilisation des generics possible
    public static Boolean isEmpty(Set<Object> s) {
        Boolean isEmpty = false;
        if (s == null || s.isEmpty()) {
            isEmpty = true;
        }
        return isEmpty;
    }
    */
   
    /**
     * [removeBlank description]
     * @param stringList [description]
     */
    /*
    public static List<String> removeBlank(List<String> stringList) {
        List<String> notBlankStringList = new List<String>();
        if (isNotEmpty(stringList)) {
            for (String elt : stringList) {
                if (String.isNotBlank(elt)) {
                    notBlankStringList.add(elt);
                }
            }
        }
        return notBlankStringList;
    }
    */

   /**
    * [removeBlank description]
    * @param stringList [description]
    */
    /*public static void removeBlank(List<String> stringList) {
        if (isNotEmpty(stringList)) {
            for (Integer i=stringList.size()-1; i>=0; i--) {
                String elt = stringList.get(i);
                if (String.isBlank(elt)) {
                    stringList.remove(i);
                }
            }
        }
    }*/

    /**
     * [removeIndex description]
     * @param  objects    [description]
     * @param  beginIndex [description]
     * @param  endIndex   [description]
     * @return            [description]
     */
    /*public static List<Object> removeIndex(List<Object> objects, Integer beginIndex, Integer endIndex) {
        List<Object> removedItems = new List<Object>();
        if (isNotEmpty(objects)) {
            // Begin
            Integer beginIndexOk = null;
            if (beginIndex >= 0) {
                beginIndexOk = beginIndex;
            }
            else {
                beginIndexOk = 0;   
            }
            // End
            Integer endIndexOk = null;
            if (endIndex <= objects.size()-1) {
                endIndexOk = endIndex;
            }
            else {
                endIndexOk = objects.size()-1;
            }
            // Remove
            for (Integer i=endIndexOk; i>=beginIndexOk; i--) {
                Object removedItem = objects.remove(i);
                removedItems.add(removedItem);
            }
        }
        return reverse(removedItems);
    }*/

    /**
     * [reverse description]
     * @param  objects [description]
     * @return         [description]
     */
    /*public static List<Object> reverse(List<Object> objects) {
        List<Object> reversedObjects = new List<Object>();
        if (isNotEmpty(objects)) {
            for (Integer i=objects.size()-1; i>=0; i--) {
                reversedObjects.add(objects.get(i));
            }
        }
        return reversedObjects;
    }*/

    /**
     * [listToString description]
     * @param  stringList [description]
     * @param  separator  [description]
     * @return            [description]
     */
    /*public static String listToString(List<String> stringList, String separator) {
        String listAsString = null;
        if (stringList != null) {
            listAsString = String.join(stringList, separator);
        }
        return listAsString;
    }*/

    /**
     * [listToString description]
     * @param  stringList [description]
     * @return            [description]
     */
    /*public static String listToString(List<String> stringList) {
        return listToString(stringList, ';');
    }*/

    /**
     * [stringToList description]
     * @param  listAsString [description]
     * @return              [description]
     */
    /*public static List<String> stringToList(String listAsString, String separator) {
        List<String> stringList = null;
        if (String.isNotBlank(listAsString)) {
            stringList = listAsString.split(separator);
        }
        else {
            stringList = new List<String>();
        }
        return stringList;
    }*/

    /**
     * [stringToList description]
     * @param  listAsString [description]
     * @return              [description]
     */
    /*public static List<String> stringToList(String listAsString) {
        return stringToList(listAsString, ';');
    }*/

    /**
     * [listToUniqueString : transforme une list en String en sans les doublons]
     * @param  stringList [description]
     * @return            [description]
     */
    /*public static List<String> listToUniqueList(List<String> stringList) {
        List<String> uniqueStringList = null;
        if (isNotEmpty(stringList)) {
            Set<String> stringSet = new Set<String>(stringList);
            uniqueStringList = new List<String>(stringSet);
            removeBlank(uniqueStringList);
            uniqueStringList.sort();
        }
        else {
            uniqueStringList = new List<String>();
        }
        return uniqueStringList;
    }*/
   
   /**
    * [listToUniqueString : transforme une list en String en sans les doublons]
    * @param  stringList [description]
    * @return            [description]
    */
    /*public static String listToUniqueString(List<String> stringList) {
        List<String> uniqueStringList = listToUniqueList(stringList);
        String uniqueString = listToString(uniqueStringList);
        return uniqueString;
    }*/

    /**
     * [stringToUniqueList description]
     * @param  listAsString [description]
     * @return              [description]
     */
    /*public static List<String> stringToUniqueList(String listAsString) {
        List<String> stringList = stringToList(listAsString);
        List<String> uniqueStringList = listToUniqueList(stringList);
        return uniqueStringList;
    }*/

    /**
     * [addToUniqueString description]
     * @param  uniqueStringToAdd [description]
     * @param  uniqueString      [description]
     * @return                   [description]
     */
    /*public static String addToUniqueString(List<String> uniqueStringListToAdd, List<String> uniqueStringList) {
        uniqueStringList.addAll(uniqueStringListToAdd);
        String uniqueStringResult = listToUniqueString(uniqueStringList);
        return uniqueStringResult;
    }*/

    /**
     * [addToUniqueString description]
     * @param  uniqueStringToAdd [description]
     * @param  uniqueString      [description]
     * @return                   [description]
     */
    /*public static String addToUniqueString(String uniqueStringToAdd, List<String> uniqueStringList) {
        List<String> uniqueStringListToAdd = stringToUniqueList(uniqueStringToAdd);
        String uniqueStringResult = addToUniqueString(uniqueStringListToAdd, uniqueStringList);
        return uniqueStringResult;
    }*/

    /**
     * [addToUniqueString description]
     * @param  uniqueStringToAdd [description]
     * @param  uniqueString      [description]
     * @return                   [description]
     */
    /*public static String addToUniqueString(List<String> uniqueStringListToAdd, String uniqueString) {
        List<String> uniqueStringList = stringToUniqueList(uniqueString);
        String uniqueStringResult = addToUniqueString(uniqueStringListToAdd, uniqueStringList);
        return uniqueStringResult;
    }*/

    /**
     * [addToUniqueString description]
     * @param  uniqueStringToAdd [description]
     * @param  uniqueString      [description]
     * @return                   [description]
     */
    /*public static String addToUniqueString(String uniqueStringToAdd, String uniqueString) {
        List<String> uniqueStringListToAdd = stringToUniqueList(uniqueStringToAdd);
        List<String> uniqueStringList = stringToUniqueList(uniqueString);
        String uniqueStringResult = addToUniqueString(uniqueStringListToAdd, uniqueStringList);
        return uniqueStringResult;
    }*/

    /**
     * [contains description]
     * @param  elementToSearch [description]
     * @param  uniqueString    [description]
     * @return                 [description]
     */
    /*public static Boolean contains(String elementToSearch, String listAsString) {
        Boolean contains = false;
        List<String> stringList = stringToList(listAsString);
        Set<String> stringSet = new Set<String>(stringList);
        if (stringSet.contains(elementToSearch)) {
            contains = true;
        }
        return contains;
    }*/

    /**
     * [contains description]
     * @param  elementToSearch [description]
     * @param  listRef         [description]
     * @return                 [description]
     */
    /*public static Boolean contains(Object elementToSearch, List<Object> listRef) {
        Boolean contains = false;
        if (isNotEmpty(listRef)) {
            for (Object elt : listRef) {
                if (SObjectUtils.equals(elt, elementToSearch)) {
                    contains = true;
                }
            }
        }
        return contains;
    }*/

    /**
     * [getFirst description]
     * @param  listRef [description]
     * @return         [description]
     */
    /*public static Object getFirst(List<Object> listRef) {
        Object first = null;
        if (isNotEmpty(listRef)) {
            first = listRef[0];
        }
        return first;
    }*/

    /**
     * [instanceOfCollection description]
     * @param  obj [description]
     * @return     [description]
     */
    /*public static Boolean instanceOfCollection(Object obj) {
        Boolean instanceOfCollection = false;
        if (obj instanceof List<Object>) {
            instanceOfCollection = true;
        }
        else if (obj instanceof Set<Object>) {
            instanceOfCollection = true;
        }
        else if (obj instanceof Map<Object, Object>) {
            instanceOfCollection = true;
        }
        return instanceOfCollection;
    }*/

}