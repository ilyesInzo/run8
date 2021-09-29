public class AP01_Objective_Rules{
    /*@@qama
    * Attributes a valid allocation to an objective 
    */
    private static final Integer year = system.today().year()-1;
    private static final Integer nextYear = system.today().year()+1;
    
    public static void objectiveReAffectation( list<Objectives__c> lObjectives){
        system.debug('--- entering objectiveReAffectation ----'+lObjectives.size());
        //get all keys of valid allocation corresponding to the used invalid ones
        set<string> setAllocationKeys = new set<string>();
        for(Integer i=0; i<lObjectives.size();i++){
            if(lObjectives[i].alloc_valid_to_date__c < date.TODAY() 
            || lObjectives[i].sales_allocation__c == null){
                String key = lObjectives[i].Account__c +'_'+ lObjectives[i].Sub_Segment__c +'_'+'4000-12-31' ;
                system.debug('--KEY--'+key);
                setAllocationKeys.add(key);
            }//end if alloc is valid
        }//end for
        
        //create a map of alloc key to alloc id
        map<string, id> mapKeyToAllocId = new map<string , id>();
        for(Sales_allocations__c alloc : [select id, Sales_Allocation_Unique_Checker__c from Sales_Allocations__c where Sales_Allocation_Unique_Checker__c in :setAllocationKeys]){
            mapKeyToAllocId.put(alloc.Sales_Allocation_Unique_Checker__c , alloc.id);   
        }       
        system.debug('--- setAllocationKeys '+setAllocationKeys.size());
        
        //Update objectives
        set<Objectives__c> objectivesToUpdate = new set<objectives__c>();
        for(Integer i=0; i<lObjectives.size();i++){             
            if(lObjectives[i].alloc_valid_to_date__c < date.TODAY() 
            || lObjectives[i].sales_allocation__c == null){
                
                lObjectives[i].Sales_Allocation__c = mapKeyToAllocId.get(lObjectives[i].Account__c +'_'+ lObjectives[i].Sub_Segment__c +'_'+'4000-12-31');
                objectivesToUpdate.add(lObjectives[i]);             
            }//end if lObjectives.allocdate <Today                  
        }//end for lObjectives
        
        system.debug('---list to update --- '+objectivesToUpdate.size());
        if(objectivesToUpdate.size() >0){
            list<Objectives__c> liobjectivesToUpdate = new list<objectives__c>();
            liobjectivesToUpdate.addAll(objectivesToUpdate);
            update liobjectivesToUpdate ;   
        }           
            
        system.debug('--- exiting objectiveReAffectation ----');    
    }        
    
    public static void ObjectiveLostRetention(List<Objectives__c> lObjectives){
       
        
        //set<Id> quoteIds = new set<Id>();
        set<Id> accIds = new set<Id>();
        set<Id> prodIds = new set<Id>();
        for(Objectives__c obj: lObjectives){
             accIds.add(obj.account__c);
            prodIds.add(obj.Sub_Segment__c);
        }
        
        //Got Quote Line Items from Objectives details
        List<QuoteLineItem > lQlis = [Select Quote.AccountId, Quote.Date_Quote_for_Lost__c, Quote.Status, Quote.Opportunity.Quote_Type__c, Product2Id, Total_Sales_value_k__c,Production_Plant__c From QuoteLineItem where Calendar_year(Quote.Date_Quote_for_Lost__c) >:year 
          and Calendar_year(Quote.Date_Quote_for_Lost__c)<:nextYear  and Quote.AccountId in :accIds and Product2Id in :prodIds and Quote.Status='Lost' and Quote.Opportunity.Quote_Type__c='Retention'  order by Quote.Date_Quote_for_Lost__c];
        
       
        //Set Monthly Achievment
        for (Objectives__c obj : lObjectives) {
            double Lost_Retention=0;
           for (QuoteLineItem qli : lQlis) {
                try{
                	Lost_Retention += ( Date.valueOf(obj.Date__c).year() == Date.valueOf(qli.Quote.Date_Quote_for_Lost__c).year() && Date.valueOf( obj.Date__c).month() == Date.valueOf(qli.Quote.Date_Quote_for_Lost__c).month() && obj.Sub_Segment__c == qli.Product2Id && obj.Account__c == qli.Quote.AccountId  &&  (obj.Plant__r.Plant_Code__c == qli.Production_Plant__c || obj.Plant__r.Name == qli.Production_Plant__c)) ? qli.Total_Sales_value_k__c : 0;
                } catch ( exception e ){}
            }
            obj.Lost_Retention__c=Lost_Retention;
        }
        
        update lObjectives;       
    }
       
    public static void ObjectiveNetNewBusiness(List<Objectives__c> lObjectives){
        
        set<Id> accIds = new set<Id>();
        set<Id> prodIds = new set<Id>();
        for(Objectives__c obj: lObjectives){
             accIds.add(obj.account__c);
            prodIds.add(obj.Sub_Segment__c);
        }
        
        //Got Quote Line Items from Objectives details
        List<QuoteLineItem > lQlis = [Select Quote.AccountId, Quote.date_Quote_Won__c, Quote.Status, Product2Id, Total_Sales_value_k__c,Production_Plant__c From QuoteLineItem where Calendar_year(Quote.date_Quote_Won__c) >:year and  Calendar_year(Quote.date_Quote_Won__c) <:nextYear
            and Quote.AccountId in :accIds and Product2Id in :prodIds and Quote.Status='Won' and (Quote.Opportunity.Contract__c = 'No' or Quote.Opportunity.Contract__c = null) order by Quote.date_Quote_Won__c];
        
       
        
        //Set Monthly Achievment
        for (Objectives__c obj : lObjectives) {
            double Monthly_Achievment=0;
            for (QuoteLineItem qli : lQlis) {
              Try{
                    if(( Date.valueOf(obj.Date__c).year() == Date.valueOf(qli.Quote.date_Quote_Won__c).year() && Date.valueOf(obj.Date__c).month() == Date.valueOf(qli.Quote.date_Quote_Won__c).month() && obj.Sub_Segment__c == qli.Product2Id && obj.Account__c == qli.Quote.AccountId &&  (obj.Plant__r.Plant_Code__c == qli.Production_Plant__c || obj.Plant__r.Name == qli.Production_Plant__c)) )
                    {
                        Monthly_Achievment +=  qli.Total_Sales_value_k__c;
                    }
                } Catch( exception e ){}
            
            }
            obj.Monthly_Achievment__c=Monthly_Achievment;
        }
        
        update lObjectives;
    }
    
    public static void ObjectiveWonContract(List<Objectives__c> lObjectives){
       
        set<Id> accIds = new set<Id>();
        set<Id> prodIds = new set<Id>();
        for(Objectives__c obj: lObjectives){        
            accIds.add(obj.account__c);
            prodIds.add(obj.Sub_Segment__c);
        }
        
        //Got Quote Line Items from Objectives details
        List<QuoteLineItem > lQlis = [Select Monthly_Sales_Value__c, Quote.Opportunity.Duration_Y__c, Quote.AccountId, Quote.date_Quote_Won__c, Renewal_Rate__c, Quote.Status, Product2Id, Total_Sales_value_k__c,Production_Plant__c From QuoteLineItem where Quote.Opportunity.Contract__c = 'Yes'
            and Quote.AccountId in :accIds and Product2Id in :prodIds and Quote.Status='Won'  and Calendar_year(Quote.date_Quote_Won__c) >=:year and Calendar_year(Quote.date_Quote_Won__c) <=: nextYear order by Quote.date_Quote_Won__c];
        for (Objectives__c obj : lObjectives) {
            obj.Won_Contract__c =0;
        }
               
        //Set Won Contract
        for (Objectives__c obj : lObjectives) {          
           for (QuoteLineItem qli : lQlis) {
             Try{ if(((obj.Date__c.year() == qli.Quote.Date_Quote_Won__c.year() && obj.Date__c.month() == qli.Quote.Date_Quote_Won__c.month())
                    ||(obj.Date__c >= qli.Quote.Date_Quote_Won__c && obj.Date__c <= (qli.Quote.Date_Quote_Won__c.addYears(1)-30))) 
                    && obj.Sub_Segment__c == qli.Product2Id && obj.Account__c == qli.Quote.AccountId &&  (obj.Plant__r.Plant_Code__c == qli.Production_Plant__c || obj.Plant__r.Name == qli.Production_Plant__c)){
                    
                        obj.Won_Contract__c += (qli.Quote.Opportunity.Duration_Y__c != null && qli.Monthly_Sales_Value__c != null) ? qli.Monthly_Sales_Value__c : 0;
                  }
                } Catch( exception e ){}
           
             }
        }
        update lObjectives;
    }
    
    public static void ObjectiveMonthly_Objective_Cur(List<Objectives__c> lObjectives){
        for (Objectives__c obj : lObjectives) {
            obj.Monthly_Objective_Cur__c=obj.Monthly_Objective__c;
        } 
         update lObjectives;
     }    
    
    public static void kamObjectiveshare(List<Objectives__c> objectivelist){
        //Check matching between Objectives sales allocation
        Set<Id> filteredObjectivesIds = new Set<Id>();
        List<Objectives__c> filteredObjectives = new List<Objectives__c>();
        for (Objectives__c obj : objectivelist) {
            if(obj.Account__c == obj.Sales_Allocation__r.Account__c && obj.Sub_segment__c == obj.Sales_Allocation__r.Product_Sub_Segment__c) {
                filteredObjectives.add(obj);
                filteredObjectivesIds.add(obj.Id);
            }
        }
        
        system.debug('--- Filtered Objective  ----'+filteredObjectives);
        
        //Remove old Objectives share
        List<Objectives__Share> lObjShareToRemove = [SELECT Id From Objectives__Share WHERE ParentId in :filteredObjectivesIds and AccessLevel != 'All'];
        delete lObjShareToRemove;
        
        
        //Process add Objectif Share for each sales member of the filtered objectives list
        List<Objectives__Share> objectiveShare = new List<Objectives__Share>();
        for(Objectives__c obj : filteredObjectives){
            if(obj.Sales_Allocation__r.Sales_Team__r.KAM__c != null) {
                Objectives__Share objShr  = new Objectives__Share();
                objShr.ParentId = obj.Id;
                objShr.AccessLevel = 'Edit';
                objShr.UserOrGroupId = obj.Sales_Allocation__r.Sales_Team__r.KAM__c;
                objectiveShare.add(objShr);
            }
            if(obj.Sales_Allocation__r.Sales_Team__r.Manager__c != null) {
                Objectives__Share objShr  = new Objectives__Share();
                objShr.ParentId = obj.Id;
                objShr.AccessLevel = 'Edit';
                objShr.UserOrGroupId = obj.Sales_Allocation__r.Sales_Team__r.Manager__c;
                objectiveShare.add(objShr);
            }
            if(obj.Sales_Allocation__r.Sales_Team__r.Director__c != null) {
                Objectives__Share objShr  = new Objectives__Share();
                objShr.ParentId = obj.Id;
                objShr.AccessLevel = 'Edit';
                objShr.UserOrGroupId = obj.Sales_Allocation__r.Sales_Team__r.Director__c;
                objectiveShare.add(objShr);
            }
            if(obj.Sales_Allocation__r.Sales_Team__r.Additional__c != null) {
                Objectives__Share objShr  = new Objectives__Share();
                objShr.ParentId = obj.Id;
                objShr.AccessLevel = 'Edit';
                objShr.UserOrGroupId = obj.Sales_Allocation__r.Sales_Team__r.Additional__c;
                objectiveShare.add(objShr);
            }
        }
        
        Database.SaveResult[] lsr = Database.insert(objectiveShare,false);
    }    
       
    public static void PlantObjectiveshare(List<Objectives__c> objectivelist){
        set<Id> plantids = new set<Id>();
        /*
        List<Objectives__c> objectivelist1 = [Select Id, Plant__c From Objectives__c where Plant__c != null and createdDate =:date.today()];
        */
        for(Objectives__c obj : objectivelist){
            plantids.add(obj.Plant__c);
        }
        
        map<Id, set<Id>> mapplantusers = new map<Id, set<Id>>();
        List<Plant_Segment_Users__c> plantseglst = [select Id, Plant_and_Cluster__c, Plant_and_Cluster__r.Name, User__c from Plant_Segment_Users__c where Plant_and_Cluster__c in:plantids];
        for(Plant_Segment_Users__c psuser : plantseglst){
            set<Id> tempset = (mapplantusers.get(psuser.Plant_and_Cluster__c) == null)?new set<Id>() : mapplantusers.get(psuser.Plant_and_Cluster__c);
            tempset.add(psuser.User__c);
            mapplantusers.put(psuser.Plant_and_Cluster__c, tempset);
        }
        
        List<Objectives__Share> objectiveShare = new List<Objectives__Share>();        
        for(Objectives__c obj : objectivelist){
            set<Id> tempset = (mapplantusers.get(obj.Plant__c) == null)?new set<Id>() : mapplantusers.get(obj.Plant__c);
            for(Id userid : tempset){
                Objectives__Share objShr  = new Objectives__Share();
                objShr.ParentId = obj.Id;
                objShr.AccessLevel = 'Edit';
                objShr.UserOrGroupId = userid ;
                objShr.RowCause = 'Plant__c';
                objectiveShare.add(objShr);
            }
        }
        
        Database.SaveResult[] lsr = Database.insert(objectiveShare,false);
    }
    
    public static void SubSegmentObjectiveshare(List<Objectives__c> objectivelist){
        set<Id> subSegmentids = new set<Id>();

        for(Objectives__c obj : objectivelist){
            subSegmentids.add(obj.Sub_Segment__c);
        }
        system.debug('--------subSegmentidsiii---------'+ subSegmentids);
        
        map<Id, set<Id>> mapsubsegusers = new map<Id, set<Id>>();
        List<Plant_Segment_Users__c> plantseglst = [select Id, Product__c, User__c from Plant_Segment_Users__c where Product__c in:subSegmentids];
        system.debug('--------plantseglst---------'+ plantseglst);
        for(Plant_Segment_Users__c psuser : plantseglst){
            set<Id> tempset = (mapsubsegusers.get(psuser.Product__c) == null)?new set<Id>() : mapsubsegusers.get(psuser.Product__c);
            tempset.add(psuser.User__c);
            mapsubsegusers.put(psuser.Product__c, tempset);
        }
        system.debug('--------mapsubsegusers---------'+ mapsubsegusers);
        
        List<Objectives__Share> objectiveShare = new List<Objectives__Share>();        
        for(Objectives__c obj : objectivelist){
            set<Id> tempset = (mapsubsegusers.get(obj.Sub_Segment__c) == null)?new set<Id>() : mapsubsegusers.get(obj.Sub_Segment__c);
            for(Id userid : tempset){
                Objectives__Share objShr  = new Objectives__Share();
                objShr.ParentId = obj.Id;
                objShr.AccessLevel = 'Edit';
                objShr.UserOrGroupId = userid ;
                objShr.RowCause = 'Segment__c';
                system.debug('--- objShr-----' + objShr);
                objectiveShare.add(objShr);
            }
        }

        Database.SaveResult[] lsr = Database.insert(objectiveShare,false);
    }
   

}