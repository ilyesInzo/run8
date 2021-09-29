public class AP00_PM_UtilityMethods {
/*****************************************************************************
 * Author           : Comforth
 * Purpose          : Utility methods for PricematriX devs
 * Notes            : 
 * History
   Date         Modified By         Description
   ------------ ---------------     -------------------------------------------
   09-FEB-2017  Gulshan             Initial version
 *****************************************************************************/ 
    
    public static final String FIELD_TYPE_DOUBLE = 'DOUBLE';
    public static final String FIELD_TYPE_CURRENCY = 'CURRENCY';
    public static final String FIELD_TYPE_PERCENT = 'PERCENT';
    public static final String FIELD_TYPE_INTEGER = 'INTEGER';
    public static final Set <String> NUMERIC_FIELDS = new Set <String>{FIELD_TYPE_DOUBLE, FIELD_TYPE_CURRENCY, FIELD_TYPE_PERCENT, FIELD_TYPE_INTEGER};

    // method which returns all fields for SOQL
    public static String getAllFieldsForSOQL(String sObjectName){
        Map<String, Schema.SObjectType> mapGlobalDescribe  = Schema.getGlobalDescribe();
        if(!mapGlobalDescribe.containsKey(sObjectName)){
            return null;        
        }
        Schema.SObjectType sObjType = mapGlobalDescribe.get(sObjectName);
        Schema.DescribeSObjectResult descResult = sObjType.getDescribe();
        
        List <String> listFieldNames = new List <String>( descResult.fields.getMap().keySet() );
		
		return ' SELECT ' +
                String.join( listFieldNames, ',' ) +
                ' FROM ' +
                descResult.getName();
    }

    public static SObject saveFields(String SObjectName, Map <String, Object> mapValues, Id recordId){
        Boolean bRecordUpdated = false;
        Map<String, Schema.SObjectType> mapGlobalDescribe  = Schema.getGlobalDescribe();
        Schema.SObjectType sObjType = mapGlobalDescribe.get(sObjectName);
        
        Schema.DescribeSObjectResult descResult = sObjType.getDescribe();
        
        SObject obj = sObjType.newSobject();
        obj.Id = recordId;

        Map <String, Schema.SObjectField> fields = descResult.fields.getMap();
        System.debug('## mapValues : ' + mapValues);

        for(String fieldName : mapValues.keySet()){
            String fieldValue = String.valueOf(mapValues.get(fieldName));
            if(fields.containsKey(fieldName.toLowerCase())){
                Schema.DescribeFieldResult fieldDescribe = fields.get(fieldName.toLowerCase()).getDescribe();
                String fieldType = String.valueOf(fieldDescribe.getType());

                if(NUMERIC_FIELDS.contains(fieldType)){
                    if(String.isBlank(fieldValue)){
                        obj.put(fieldName, null);
                    }else{
                        obj.put(fieldName, Decimal.valueOf(fieldValue));
                    }
                }else{
                    obj.put(fieldName, fieldValue);
                }
                bRecordUpdated = true;
            }
        }
        
        System.debug('## obj : ' + obj);
        if(bRecordUpdated) update obj;
        return obj;
    }
}