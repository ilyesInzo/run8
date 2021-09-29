/**
* @description Utility class for String
* @author MDK
* @date 20/11/2017
*/
public class StringUtils {

    /**
    * @description Methods which returns a random String
    * @param    length [string length]
    * @return   randStr [random String]            
    */
    public static String generateRandomString(Integer length) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < length) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

    /**
    * @description Methods which checks if a string contains a chineese character
    *              returns true if so, unless it returns false
    * @param    inputString [string to check]
    * @return   boolean [true if so, unless it returns false]            
    */
    public static Boolean containsIllegalChars(String inputString){
        System.debug(LoggingLevel.ERROR,'StringUtils.containsIllegalChars : String to check = '+InputString);
        
        string patn = System.label.patternToBlock;
        
        Pattern p = Pattern.compile(patn);
        
        Matcher m = p.matcher( InputString );       
        
        System.debug(LoggingLevel.ERROR,'StringUtils.containsIllegalChars : end checker Matcher = '+m);
        return m.find();//returns true if a chinees/japanees char is found
    
    }

    /**
     * [equals description]
     * @param  first  [description]
     * @param  second [description]
     * @return        [description]
     */
    /*public static Boolean equals(String first, String second) {
        Boolean isEquals = false;
        if (first == null && second == null) {
            isEquals = true;
        }
        else if (first != null && first.equals(second)) {
            isEquals = true;
        }
        return isEquals;
    }*/

    /**
     * [equalsNotBlank description]
     * @param  first  [description]
     * @param  second [description]
     * @return        [description]
     */
    /*public static Boolean equalsNotBlank(String first, String second) {
        Boolean isEquals = false;
        if (String.isNotBlank(first) && equals(first, second)) {
            isEquals = true;
        }
        return isEquals;
    }*/

    /**
     * [equalsIgnoreCase description]
     * @param  first  [description]
     * @param  second [description]
     * @return        [description]
     */
    /*public static Boolean equalsIgnoreCase(String first, String second) {
        Boolean isEquals = false;
        if (first == null && second == null) {
            isEquals = true;
        }
        else if (first != null && first.equalsIgnoreCase(second)) {
            isEquals = true;
        }
        return isEquals;
    }*/

    /**
     * [escapeDeveloperName description]
     * @param  str [description]
     * @return     [description]
     */
    /*public static String escapeDeveloperName(String str) {
        String formatedStr = str;
        if (String.isNotBlank(formatedStr)) {
            formatedStr = formatedStr.replaceAll('[àâ]', 'a');
            formatedStr = formatedStr.replaceAll('[ç]', 'c');
            formatedStr = formatedStr.replaceAll('[éèê]', 'e');
            formatedStr = formatedStr.replaceAll('[ùû]', 'u');
            formatedStr = formatedStr.replaceAll('[^a-zA-Z0-9]', '_');
        }
        return formatedStr;
    }*/

    /**
     * [left description]
     * @param  str [description]
     * @param  len [description]
     * @return     [description]
     */
    /*public static String left(String str, Integer len) {
        return (str != null && str.length()>len) ? str.substring(0, len) : str; 
    }*/

    /**
     * [right description]
     * @param  str [description]
     * @param  len [description]
     * @return     [description]
     */
    /*public static String right(String str, Integer len) {
        return (str != null && str.length()>len) ? str.substring(str.length()-len, str.length()) : str; 
    }*/

    /*
    public static String maxRichTextLength(String richTextValue) {
        // Max size : 32768
        Integer maxLength = 32768;
        if (richTextValue != null && richTextValue.length()>maxLength) {
            return richTextValue.substring(0, maxLength);
        }
        else {
            return richTextValue;
        }
    }
    */

}