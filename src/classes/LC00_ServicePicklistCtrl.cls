public class LC00_ServicePicklistCtrl {


    @AuraEnabled  
    public static List<String> getValues(String objectName, String fieldName, Map<String,String> parameters){
    
        List<string> fnamelst= fieldName.split(',');
        
        String sQuery = 'SELECT '+fieldName+' FROM '+objectName + ' WHERE ' + fnamelst[0] + ' != null ';
                
        for(String field :  parameters.keySet()){
            sQuery += ' AND ';
            sQuery += field + ' = \'' + parameters.get(field) + '\'';
        }
                
        sQuery += ' ORDER BY ' + fnamelst[0];
        
        //system.debug('******sQuery*********' + sQuery);
        
        set<String> listValues = new set<String>();                
        for(SObject so : Database.query(sQuery)){
        
            string value = '';
            for(string s : fnamelst){            
                value += (value == '')?String.ValueOf(so.get(s)):';' + String.ValueOf(so.get(s));
            }
            
            listValues.add(value);
            
            //system.debug('******fieldName******' + fieldName);
            //system.debug('******fieldNameVALUE******' + value);
        }
                
        return new List<String>(listValues); 
    }


}