public class LC00_DependentPicklistCtrl {
/*****************************************************************************
 * Author           : Comforth
 * Purpose          : Apex controller for lightning component LC00_DependentPicklist & LC00_DependentButtons
 * Notes            : 
 * History
   Date         Modified By         Description
   ------------ ---------------     -------------------------------------------
   02-FEB-2017  Gulshan             Initial version
 *****************************************************************************/
 /*
    @AuraEnabled
    public static SObject saveField(String sObjectName, String fieldName, String fieldValue, Id recordId){
        Map <String, String> mapValues = new Map <String, String> {fieldName => fieldValue};
        return AP00_PM_UtilityMethods.saveFields(sObjectName, mapValues, recordId);
    }
    
    
    @AuraEnabled    
    public static List<String> getValues(String name, String tableName, String location, String sObjectName, Map<String,String> dependsOnMapValues){
        System.debug('Name:'+name);
        System.debug('Table Name:'+tableName);
        System.debug('Location:'+location);
        System.debug('sObject Name:'+sObjectName);
        System.debug('Depends On dependsOnMapValues:'+dependsOnMapValues);
        
        String sQuery = 'SELECT '+name+' FROM '+sObjectName+ buildWhereCondition(sObjectName,tableName, location, dependsOnMapValues);
        
        sQuery += ' ORDER BY ' + name;
        
        System.debug('##################### sQuery = '+sQuery);
        
        List <String> listValues = new List <String>();
        
        for(PM_Tubes_Config__c ptc : (List <PM_Tubes_Config__c>) Database.query(sQuery)){
            System.debug(ptc.get(name));
            listValues.add(String.valueOf(ptc.get(name)));
        }
        System.debug(listValues);
        return listValues; 
    }
    */
    /**
* Helper methods to build the dependsOn where clause
*/
/*
    public static String buildWhereCondition(String sObjectName, String tableName, String location, Map <String,Object> whereCond){
        //String whereCondStr = ' WHERE Table_name__c = \''+tableName+'\' AND Location__c = \''+location+'\' ';
        String whereCondStr = ' WHERE ';
        System.debug('## whereCond : ' + whereCond);
        for(String field :  whereCond.keySet()){
            String condValue = String.valueOf(whereCond.get(field));
            System.debug('## field : ' + field);
            System.debug('## value : ' + condValue);
            // RBE: Check if the fiels if number of text
            if(isNumber(sObjectName, field)){
                condValue = condValue;
            }else{
                condValue = '\'' + condValue + '\'';
            }
            
            // GDO : Prevent query crash if condValue is empty
            if(String.isBlank(condValue)){
                condValue = 'null';
            }
            
            whereCondStr = whereCondStr + field +' = '+condValue + ' AND ';
        }
        whereCondStr = whereCondStr.removeEnd(' AND ');
        System.debug('################### whereCondStr:'+whereCondStr);
        return whereCondStr;
    }
    
    // RBE: Describe a field and check if type is number (Double)
    public static boolean isNumber(String SObjectName, String fieldName){
        System.debug('##' + SObjectName + ':' + fieldName);
        // sObject types to describe
        String[] sObjects = new String[]{SObjectName};
            DescribeSObjectResult[] dsr =  Schema.describeSObjects(sObjects);
        SobjectType sObjType = dsr[0].getSobjectType();
        return (sObjType.getDescribe().fields.getMap().get(fieldName.toLowerCase()).getDescribe().getType() == DisplayType.DOUBLE) ; 
    }*/
}