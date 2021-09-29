public without sharing class Quotes_by_Status_Controller {
    
    @AuraEnabled
    public static Boolean isAllowed(String recordId){
        List<Sales_Allocations__c> allocs = [Select Sales_Team__r.Director__c,Sales_Team__r.Manager__c, Sales_Team__r.KAM__c, Sales_Team__r.Additional__c, Sales_Team__r.Valid_From__c, Sales_Team__r.Valid_To__c  from Sales_Allocations__c Where Account__c = :recordId and Valid_From__c <= today and Valid_To__c >= today];
        set<String> allowedUsers = new set<String>();
        //Ale 05/09 : Users with marketing profile are now allowed
        //Ale 13/09 : Other profiles are allowed
        String marketingId = [Select id from Profile Where Name = 'Marketing' limit 1].Id;
        String systadm = [Select id from Profile Where Name = 'System Administrator' limit 1].Id;
        String plantId = [Select id from Profile Where Name = 'Plant' limit 1].Id;
        String funcadmId = [Select id from Profile Where Name = 'Functionnal Administrator' limit 1].Id;
        for(User usr : [Select id from User Where ProfileId = :marketingId or ProfileId = :systadm or ProfileId = :plantId or ProfileId = :funcadmId]){
            allowedUsers.add(usr.Id);
        }
        for(Sales_Allocations__c alloc : allocs){
            if(alloc.Sales_Team__r.Valid_From__c <= system.today() && alloc.Sales_Team__r.Valid_To__c >= system.today()){
                if(alloc.Sales_Team__r.Director__c != null){
                    allowedUsers.add(alloc.Sales_Team__r.Director__c);
                }
                if(alloc.Sales_Team__r.Manager__c != null){
                    allowedUsers.add(alloc.Sales_Team__r.Manager__c);
                }
                if(alloc.Sales_Team__r.KAM__c != null){
                    allowedUsers.add(alloc.Sales_Team__r.KAM__c);
                }
                if(alloc.Sales_Team__r.Additional__c != null){
                    allowedUsers.add(alloc.Sales_Team__r.Additional__c);
                }
            }            
        }
        if(allowedUsers.contains(UserInfo.getUserId())){
            system.Debug('user allowed');
            return true;
        }
        else{
            system.Debug('user not allowed');
            return false;
        }
    }
    
    
    
    @AuraEnabled
    public static String getData(String recordId){
        Map<String, List<Integer>> data = new Map<String, List<Integer>>();
        
        //data0 est une map qui aux 4 product lines associe une Map<QuoteId, Status>
        Map<String, Map<String, set<String>>> data0 = new Map<String, Map<String, set<String>>>();
        
        //Initialisation de data0
        
        data0.put('Tubes', new Map<String, set<String>>());
        data0.put('Dispensing', new Map<String, set<String>>());
        data0.put('Beauty Solutions', new Map<String, set<String>>());
        data0.put('CRP', new Map<String, set<String>>());
        
        //Remplissage de data0
        
        Integer ref = Integer.valueOf(System.Label.LBL_Reference_Year_For_Quotes_by_Status_Report);
        Date dateRef = Date.newInstance(ref, 1, 1);
        system.Debug('date ref : ' + dateRef);
     ///   system.Debug('qlis soql size ' + [Select Id from QuoteLineItem].size());
        List<QuoteLineItem> qlis = [Select QuoteId, Quote.Status, Product_line__c from QuoteLineItem Where Quote.Opportunity.AccountId = :recordId and (Quote.Decision_Date__c > :dateRef OR Quote.Decision_Date__c = null)];        
        system.Debug('qlis size : ' + qlis.size());
        for(QuoteLineItem qli : qlis){
            if(qli.Product_line__c == 'Tubes' || qli.Product_line__c == 'Dispensing' || qli.Product_line__c == 'Beauty Solutions' || qli.Product_line__c == 'CRP'){
                if(data0.get(qli.Product_line__c).containsKey(qli.Quote.Status)){
                    data0.get(qli.Product_line__c).get(qli.Quote.Status).add(qli.QuoteId);
                }
                else{
                    data0.get(qli.Product_line__c).put(qli.Quote.Status, new Set<String>());
                    data0.get(qli.Product_line__c).get(qli.Quote.Status).add(qli.QuoteId);
                }
            }
        }
        
        //Initialisation de data
        
        data.put('Tubes', new List<Integer>());
        data.put('Dispensing', new List<Integer>());
        data.put('Beauty Solutions', new List<Integer>());
        data.put('CRP', new List<Integer>());
        
        //On remplit data
        
        for(String productline : data0.keySet()){
            
            List<Integer> quotecount = new List<Integer>();
            List<String> status = new List<String>();
            status.add('Draft');
            status.add('Presented');
            status.add('Won');
            status.add('Killed By Albea');
            status.add('Killed By Customer');
            status.add('Lost');
            
            for(Integer i=0; i<6; i++){
                if(data0.get(productline).get(status[i]) != null){
                    quotecount.add(data0.get(productline).get(status[i]).size());
                }
                else{
                    quotecount.add(0);
                }
            }
            
            data.put(productline, quotecount);
            
        }        
        
        system.Debug('Datasets : ' + data);
        
        return JSON.serialize(data);
        
    }
}