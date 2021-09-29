public class LC01_Message_Global_Config_Ctrl{

    @AuraEnabled
    public static map<String, String> getmessagevalueinfo(String value,String tablename,String sObjectName,String fieldvalue,String fieldreturnval,String location,String tubesegment){

            map<String, String> mapmsgval = new map<String, String>();
            mapmsgval.put('','');
            mapmsgval.put(null,'');
            String query = 'SELECT ' + fieldreturnval + ',' + fieldvalue + ' FROM ' + sObjectName;
            query += ' WHERE Location__c =:location';
            query += ' AND Table_name__c =:tablename';
            query += ' AND Tubes_segment__c =:tubesegment';
            query += ' AND Active__c = true';
            query += ' AND ' + fieldvalue + ' != null ';
            
            Database.Query(query);
            for(PM_Tubes_Config__c tubecon : (List <PM_Tubes_Config__c>) Database.query(query)){
                string valstr = (tubecon.get(fieldreturnval) == null)?'':String.ValueOf(tubecon.get(fieldreturnval));
                mapmsgval.put(String.ValueOf(tubecon.get(fieldvalue)), valstr );                
            }
            
        return mapmsgval ;
    }


}