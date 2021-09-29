public class LC00_DependentFieldsCtrl {

    @AuraEnabled  
    public static Map<String, List<String>> getMapListValues(String objectName, String fieldName, Map<String,String> parameters, List<String> dependentfields, String savedFieldname){
    
        List<string> fnamelst= fieldName.split(',');
        
        String dependflds = String.join(dependentfields, ',');
        String selectfields = (dependentfields.size() > 0) ? fieldName + ',' + dependflds :fieldName;
        
        String sQuery = 'SELECT '+ selectfields +' FROM '+objectName + ' WHERE ' + fnamelst[0] + ' != null ';
                
        for(String field :  parameters.keySet()){
            sQuery += ' AND ';
            sQuery += field + ' = \'' + parameters.get(field) + '\'';
        }
                
        sQuery += ' ORDER BY ' + fnamelst[0];
        
        //system.debug('#### ******savedFieldname********* : ' + savedFieldname);
        //system.debug('#### ******sQuery********* : ' + sQuery);
        
        Map<String, List<String>> mapValues = new Map<String, List<String>>();                
        for(SObject so : Database.query(sQuery)){           
            string dependname = '';
            for(string d : dependentfields){
                dependname += (so.get(d) == null)?'':String.ValueOf(so.get(d));
            }
            dependname = (dependname == '')?savedFieldname:dependname;
            
            //system.debug('#### ******dependname key********* : ' + dependname );
        
            List<String> templist = (mapValues.get(dependname) == null)?new List<String>():mapValues.get(dependname);
            string value = '';
            for(string s : fnamelst){            
                value += (value == '')?String.ValueOf(so.get(s)):';' + String.ValueOf(so.get(s));
            }            
            templist.add(value);
            
            Set<String> myset = new Set<String>();
            List<String> result = new List<String>();
            myset.addAll(templist);
            result.addAll(myset);
            
            mapValues.put(dependname, result);            
        }
                
        return mapValues; 
    }


}