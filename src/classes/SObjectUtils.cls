/**
* @description Utility class for SObject
* @author MDK, EWA
* @date 20/11/2017
*/
public class SObjectUtils {
	//Attributs of the class SObjectUtils 
	public static string LOG_CLASS_NAME = 'SObjectUtils';

	//Methods of the class SObjectUtils  
	/**
	 * [toListOfObject : retrieve a list of Object]
	 * @param  sObjects [description]
	 * @return          [description]
	 */
    /*public static List<Object> toListOfObject(List<SObject> sObjects, String fieldName) {
	    List<Object> values = new List<Object>();
	    if (sObjects != null && !sObjects.isEmpty()) {
		    for (SObject sObj : sObjects) {
		        if (sObj != null) {
		        	Object fieldValue = sObj.get(fieldName);
		        	if (fieldValue  != null) {
		        		values.add(fieldValue);
		        	}
		        }
		    }
	    }
	    return values;
	}*/

	/**
	 * @description [getSObjectType description]
	 * @param  sObjectName [description]
	 * @return             [description]
	 */
	/*public static Schema.SObjectType getSObjectType(String sObjectName) {
		Schema.SObjectType sObjectType = null;
		if (String.isNotBlank(sObjectName)) {
			Map<String, Schema.SObjectType> sgd =  Schema.getGlobalDescribe(); 
			sObjectType = sgd.get(sObjectName.toLowerCase());
		}
		return sObjectType;
    }*/

    /**
     * @description [getDescribeSObjectResult description]
     * @param  sObjectType [description]
     * @return             [description]
     */
	/*public static Schema.DescribeSObjectResult getDescribeSObjectResult(Schema.SObjectType sObjectType) {
		Schema.DescribeSObjectResult describeSObjectResult = null;
		if (sObjectType != null) {
			describeSObjectResult = sObjectType.getDescribe();
		}
		return describeSObjectResult;
    }*/

    /**
     * @description [getSObjectType description]
     * @param  sObjectType [description]
     * @return             [description]
     */
	/*public static Boolean isSObjectOfType(Id sObjectId, String sObjectName) {
		//Autre facon d'appeler : User.sObjectType.getDescribe().getKeyPrefix()
		Boolean isSObjectOfType = false;
		if (String.isNotBlank(sObjectId)) {
			Schema.SObjectType sObjectType = getSObjectType(sObjectName);
			Schema.DescribeSObjectResult describeSObjectResult = getDescribeSObjectResult(sObjectType);
			if (describeSObjectResult != null) {
				String prefixRef = describeSObjectResult.getKeyPrefix();
				String prefix = String.valueOf(sObjectId).substring(0,3);
				if (equals(prefix, prefixRef)) {
					isSObjectOfType = true;
				}
			}
		}
		return isSObjectOfType;
    }*/

    /**
     * @description [getRecordTypeIdFromName description]
     * @param  recordTypeNames [description]
     * @param  sObjectName     [description]
     * @return                 [description]
     */
    /*public static List<Id> getRecordTypeIdFromName(List<String> recordTypeNames, String sObjectName) {
    	System.debug('SObjectUtils.getRecordTypeIdFromName : sObjectName=' + sObjectName + ', recordTypeNames=' + recordTypeNames);
		List<Id> rtIds = new List<Id>();
		if (CollectionUtils.isNotEmpty(recordTypeNames)) {
			Schema.SObjectType sObjectType = getSObjectType(sObjectName);
			Schema.DescribeSObjectResult describeSObjectResult = getDescribeSObjectResult(sObjectType);
			if (describeSObjectResult != null) {
        		Map<String, Schema.RecordTypeInfo> rtByName = describeSObjectResult.getRecordTypeInfosByName();
        		System.debug('SObjectUtils.getRecordTypeIdFromName : rtByName=' + rtByName);
        		if (rtByName != null) {
	        		for (String recordTypeName : recordTypeNames) {
	        			Schema.RecordTypeInfo rtInfo =  rtByName.get(recordTypeName);
	        			if (rtInfo != null) {
	        				Id rtId = rtInfo.getRecordTypeId();
	        				rtIds.add(rtId);
	        			}
	        		}
        		}
			}
		}
		return rtIds;
    }*/

    /**
     * @description returns the value of all populated field for a given record
     * @param SObject : an SObject
     * @return string : concatenated string
     */
	public static String getAllFieldsValues(SObject record){
		
		Object resultString ='';

		for (Object fieldName : record.getPopulatedFieldsAsMap().values()){ 	
			resultString+= ''+fieldName;
		} 	
			
		return (String)resultString;	
	}

    /**
     * @description check Chinese Char
     * @param newSObjects : list of SObjects
     * @return nothing
     */
    public static void checkChar(List<SObject> newSObjects) {
 
        for(SObject sobj : newSObjects){     
            if(StringUtils.containsIllegalChars(getAllFieldsValues(sobj))){
            	// for each Object has the same Tech_validation_error__c field api name
                sobj.put('Tech_validation_error__c','CH Error');             
            }               
        }
        
    }

	/**
	 * @description toListOfId : retrieve a List of Ids
	 * @param  Set of sObjects
	 * @return a List of Ids
	 */
    public static List<Id> toListOfId(Set<SObject> sObjects) {
	    //List<Id> ids = null;
	    List<Id> ids = new List<Id>();
	    if (sObjects != null && !sObjects.isEmpty()) {
	    	//ids = new List<Id>();
		    for (SObject sObj : sObjects) {
		        if (sObj != null && sObj.Id != null) {
		        	ids.add(sObj.Id);
		        }
		    }
	    }
	    return ids;
	}

	/**
	 * @description toSetOfId : retrieve a set of Ids
	 * @param  Set of sObjects
	 * @return a Set of Ids
	 */
    public static Set<Id> toSetOfId(Set<SObject> sObjects) {
		List<Id> values = toListOfId(sObjects);
		return new Set<Id>(values);
	}

	/**
	 * @description toListOfId : retrieve a list of Ids
	 * @param  List of sObjects
	 * @return a List of Ids
	 */
    public static List<Id> toListOfId(List<SObject> sObjects) {
	    //List<Id> ids = null;
	    List<Id> ids = new List<Id>();
	    if (sObjects != null && !sObjects.isEmpty()) {
	    	//ids = new List<Id>();
		    for (SObject sObj : sObjects) {
		        if (sObj != null && sObj.Id != null) {
		        	ids.add(sObj.Id);
		        }
		    }
	    }
	    return ids;
	}

	/**
	 * @description toSetOfId : retrieve a Set of Ids
	 * @param  List of sObjects
	 * @return a Set of Ids
	 */
    public static Set<Id> toSetOfId(List<SObject> sObjects) {
		List<Id> values = toListOfId(sObjects);
		return new Set<Id>(values);
	}

	/**
	 * [toListOfId : retrieve a list of Id]
	 * @param  sObjects [description]
	 * @return          [description]
	 */
    public static List<Id> toListOfId(List<SObject> sObjects, String idFieldName) {
    	//List<Id> ids = null;
	    List<Id> ids = new List<Id>();
	    if (sObjects != null && !sObjects.isEmpty()) {
	    	//ids = new List<Id>();
		    for (SObject sObj : sObjects) {
		        if (sObj != null) {
		        	Id idValue = (Id) sObj.get(idFieldName);
		        	if (String.isNotBlank(idValue)) {
		        		ids.add(idValue);
		        	}
		        }
		    }
	    }
	    return ids;
	}

	/**
	 * [toSetOfId : retrieve a set of Id]
	 * @param  sObjects [description]
	 * @return          [description]
	 */
    public static Set<Id> toSetOfId(List<SObject> sObjects, String idFieldName) {
		List<Id> values = toListOfId(sObjects, idFieldName);
		return new Set<Id>(values);
	}

	/**
	 * [toListOfString : retrieve a list of String]
	 * @param  sObjects [description]
	 * @return          [description]
	 */
    public static List<String> toListOfString(List<SObject> sObjects, String fieldName) {
	    List<String> values = new List<String>();
	    if (sObjects != null && !sObjects.isEmpty()) {
		    for (SObject sObj : sObjects) {
		        if (sObj != null) {
		        	String fieldValue = (String) sObj.get(fieldName);
		        	if (String.isNotBlank(fieldValue)) {
		        		values.add(fieldValue);
		        	}
		        }
		    }
	    }
	    return values;
	}

	/**
	 * [toSetOfString : retrieve a set of String]
	 * @param  sObjects [description]
	 * @return          [description]
	 */
    public static Set<String> toSetOfString(List<SObject> sObjects, String fieldName) {
    	List<String> values = toListOfString(sObjects, fieldName);
    	return new Set<String>(values);
	}

	/**
	 * [toMap description]
	 * @param  keyFieldName [description]
	 * @param  sObjects     [description]
	 * @return              [description]
	 */
    public static Map<Object, SObject> toMap(List<SObject> sObjects, String keyFieldName) {
		//Map<Object, SObject> resultMap = null;
		Map<Object, SObject> resultMap = new Map<Object, SObject>();
        if (sObjects != null) {
            //resultMap = new Map<Object, SObject>();
            for (SObject sObj : sObjects) {
            	Object keyFieldValue = sObj.get(keyFieldName);
            	if (keyFieldValue != null) {
                	resultMap.put(keyFieldValue, sObj);
            	}
            }
        }
	    return resultMap;
	}

	/**
	 * [toMap description]
	 * @param  idFieldName  [description]
	 * @param  sObjects     [description]
	 * @return              [description]
	 */
    public static Map<Id, List<SObject>> toMapOfListById(List<SObject> sObjects, String idFieldName) {
		//Map<Id, List<SObject>> resultMap = null;
		Map<Id, List<SObject>> resultMap = new Map<Id, List<SObject>>();
        if (sObjects != null) {
            //resultMap = new Map<Id, List<SObject>>();
            for (SObject sObj : sObjects) {
            	Id keyFieldValue = (Id) sObj.get(idFieldName);
            	if (keyFieldValue != null) {
            		List<SObject> eltList = resultMap.get(keyFieldValue);
            		if (eltList != null) {
            			eltList.add(sObj);
            			resultMap.put(keyFieldValue, eltList);
            		}
            		else {
            			resultMap.put(keyFieldValue, new List<SObject> { sObj });
            		}
            	}
            }
        }
	    return resultMap;
	}

	/**
	 * [toMap description]
	 * @param  idFieldName  [description]
	 * @param  sObjects     [description]
	 * @return              [description]
	 */
    /*public static Map<String, List<SObject>> toMapOfListByString(List<SObject> sObjects, String fieldName) {
		//Map<String, List<SObject>> resultMap = null;
		Map<String, List<SObject>> resultMap = new Map<String, List<SObject>>();
        if (sObjects != null) {
            //resultMap = new Map<String, List<SObject>>();
            for (SObject sObj : sObjects) {
            	String keyFieldValue = (String) sObj.get(fieldName);
            	if (keyFieldValue != null) {
            		List<SObject> eltList = resultMap.get(keyFieldValue);
            		if (eltList != null) {
            			eltList.add(sObj);
            			resultMap.put(keyFieldValue, eltList);
            		}
            		else {
            			resultMap.put(keyFieldValue, new List<SObject> { sObj });
            		}
            	}
            }
        }
	    return resultMap;
	}*/

	/**
	 * [toList description]
	 * @param  sObjects [description]
	 * @return          [description]
	 */
    /*public static List<Object> toList(Set<Object> objects) {
		List<Object> objectsList = null;
        if (objects != null) {
            objectsList = new List<Object>(objects);
        }
        else {
        	objectsList = new List<Object>();	
        }
	    return objectsList;
	}*/

	/**
	 * [toList description]
	 * @param  sObjects [description]
	 * @return          [description]
	 */
    /*public static List<SObject> toList(Set<SObject> sObjects) {
		List<SObject> sObjectsList = null;
        if (sObjects != null) {
            sObjectsList = new List<SObject>(sObjects);
        }
        else {
        	sObjectsList = new List<SObject>();	
        }
	    return sObjectsList;
	}*/

    /**
     * [isModified description]
     * @param  newObj     [description]
     * @param  oldObj     [description]
     * @param  fieldNames [description]
     * @return            [description]
     */
    public static Boolean isModified(SObject newObj, SObject oldObj, Set<String> fieldNames) {
    	Boolean isModified = false;
    	if (newObj != null) {
			if (oldObj == null) {
				isModified = true;
	    	}
	    	else {
	        	for (String fieldName : fieldNames) {
	            	Object newValue = newObj.get(fieldName);
	            	Object oldValue = oldObj.get(fieldName);
	            	//System.debug(LoggingLevel.ERROR,'SObjectUtils.isModified : fieldName=' + fieldName + ', newValue=' + newValue + ', oldValue=' + oldValue);
					if (!equals(newValue, oldValue)) {
						isModified = true;
						break;
					}
	        	}
	        }
	    }
        return isModified;
    }

    /**
     * [equals description]
     * @param  obj          [description]
     * @param  objToCompare [description]
     * @return              [description]
     */
    public static Boolean equals(Object obj, Object objToCompare) {
    	Boolean isEquals = false;
    	if (obj == null && objToCompare == null) {
			isEquals = true;
    	}
    	else if (obj != null && obj.equals(objToCompare)) {
			isEquals = true;
    	}
    	return isEquals;
    }

    /**
     * [getCorrespondingCode : this method return 0, 1 or 2 in function of the parameter]
     * @param  str 		   [The parameter that we are going to analyse]
     * @param  valueForOne [The value that we want to return one]
     * @return     		   [An integer : 0, 1 or 2]
     */
    public static Integer getCorrespondingCode(String str, String valueForOne){
    	if(str == valueForOne){
    		return 1;
    	}
    	else if(str != null){
    		return 2;
    	}
    	return 0;
    }

    /**
     * [generatePriceDetail : generate a new list of pricing]
     * @param  values		  			  [List<Integer> : The parameter that we are going to analyse				]
     * @param  moqDouble  	  			  [Double : 																]
     * @param  price          			  [Decimal :  																]
     * @param  externalId     			  [String :																	]
     * @param  title 		  			  [String :																	]
     * @param  section        			  [String :																	]
     * @param  qliId		  			  [String :																	]
     * @param  selectedTubeId 			  [String : 																]
     * @param  selectedDispensingConfigId [String :																	]
     * @return     			  			  [List<PM_Price_Detail__c> : une liste de PM_Price_Detail__c 				]
     */
    public static List<PM_Price_Detail__c> generatePriceDetail(List<Integer> values, Double moqDouble, Decimal price,
    														String externalId, String title, String section, String qliId,
    														String selectedTubeId, String selectedDispensingConfigId){

    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - generatePriceDetail Start');

    	//We're going to generate the corresponding PM_Price_Detail
    	List<PM_Price_Detail__c> result = new List<PM_Price_Detail__c>();
    	if(values.size() < 2){
	    	for(Integer index = 0; index < values.size()-1; index++){
	    		Integer currentValue = values.get(index);
	    		Integer nextValue = values.get(index++);
	    		PM_Price_Detail__c temp = new PM_Price_Detail__c(
	    									Price_Override__c = (moqDouble == currentValue? price: 0), 
	    									ExtId__c = externalId + currentValue, 
	    									MOQ_Min__c = currentValue, 
	    									MOQ_Max__c = nextValue, 
	    									List_Price__c = 0, 
	    									Name = title, 
	    									Section__c = section, 
	    									Quote_item__c = qliId, 
	    									PM_Selected_Tubes_Config__c = selectedTubeId, 
	    									PM_Selected_Dipsensing_Config__c = selectedDispensingConfigId);
	    	}
    	}

    	System.debug(LoggingLevel.INFO, LOG_CLASS_NAME + ' - generatePriceDetail Stop');

    	return result;
    }

    /**
     * [cleanString : will remove from the src string all the following character : ' ','-', ]
     * [              '\','(',')','/','&'                                                    ]
     * @param  src [String : the string that we want to clean 		]
     * @return 	   [String : the cleaned string						]
     */
    public static String cleanString(String src){
    	String result = src.remove(' ');
        result = result.remove('-');
        result = result.remove('\'');
        result = result.remove('(');
        result = result.remove(')');
        result = result.remove('/');
        result = result.remove('&');

        if(result.startsWith('5')){
            result =  result.replaceFirst('5', 'Five');
        }

        return result;
    }
}