public class customLookUpController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, String quoteId) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        String usrId = UserInfo.getUserId();

        List < sObject > lstOfRecords = new List < sObject > ();

        if(ObjectName == 'account'){
            //for unicity
            set < Id > setIds = new set < Id > ();

            set<String> idSubSegments = new set<String>();

            for(QuoteLineItem qli : [Select Product2Id from QuoteLineItem Where QuoteId = :quoteId]){
                idSubSegments.add(qli.Product2Id);
            }
            system.Debug('idSubSegments : ' + idSubSegments);

            // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
            // Line added by Achraf LAMZABI to handle Filters by sales Allocations
            if(quoteId != null){
                for(Sales_Allocations__c alloc : [Select id, Account__c from Sales_Allocations__c Where (Sales_Team__r.Director__c = :usrId or Sales_Team__r.Manager__c = :usrId or Sales_Team__r.KAM__c = :usrId or Sales_Team__r.Additional__c = :usrId) and Valid_From__c <= today and Valid_To__c >= today  and Product_Sub_segment__c in :idSubSegments]){
                    setIds.add(alloc.Account__c);
                }    
            }
            //Lines added by Achraf LAMZABI to handle Filters by sales Allocations
            else{
                for(Sales_Allocations__c alloc : [Select id, Account__c from Sales_Allocations__c Where (Sales_Team__r.Director__c = :usrId or Sales_Team__r.Manager__c = :usrId or Sales_Team__r.KAM__c = :usrId or Sales_Team__r.Additional__c = :usrId) and Valid_From__c <= today and Valid_To__c >= today]){
                    setIds.add(alloc.Account__c);
                }
            }
            

            //Added by Thanina , pour permettre au functionnal Admin and  Sys Admin need to see all account: Start ID
            User u = [select id, Profile.Name,ISM_Team_Member__c from User where id = :usrId];
            String sQuery = '';
             
             if(u.ISM_Team_Member__c == true || u.Profile.Name.equalsIgnoreCase('System Administrator') || u.Profile.Name.equalsIgnoreCase('Functionnal Administrator'))
                 sQuery =  'select id, Name, Account_Key_Formula__c from ' +ObjectName + ' where Name LIKE: searchKey  order by createdDate DESC limit 5';
            //------- End Id----------------
             else sQuery =  'select id, Name, Account_Key_Formula__c from ' +ObjectName + ' where Name LIKE: searchKey and id in :setIds order by createdDate DESC limit 5';
            
            lstOfRecords = Database.query(sQuery);

        }

        if(ObjectName == 'opportunity'){
            //We return only open opportunities
            String status = 'Needs Analysis';
            String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey and StageName = :status order by createdDate DESC limit 5';
            lstOfRecords = Database.query(sQuery);
        }
        
        system.debug('accounts allowed : ' + lstOfRecords);

        if(ObjectName == 'Product2'){
            //We return only open opportunities
            
            String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 3';
            lstOfRecords = Database.query(sQuery);
        }
        return lstOfRecords;
    }
}